resource "aws_security_group" "mongo_sg" {
  name        = "${var.tags.Project}-mongo-sg"
  description = "Allow SSH and kube internal access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # intentionally public SSH for exercise
  }

  # Allow EKS cluster CIDR access to MongoDB
  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = [var.kube_cidr]
    description     = "Allow Mongo access from cluster"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "mongo_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name
  iam_instance_profile = var.iam_instance_profile
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]

  user_data = <<-EOF
      #!/bin/bash
      # Update system
      yum update -y

      # Install MongoDB 6.0 (older version)
      cat <<EOM > /etc/yum.repos.d/mongodb-org-6.0.repo
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOM

      yum install -y mongodb-org

      # Enable MongoDB authentication and bind to local network only
      sed -i 's/^#security:/security:\n  authorization: "enabled"/' /etc/mongod.conf
      sed -i 's/bindIp: 127.0.0.1/bindIp: 127.0.0.1,10.0.0.0\/16/' /etc/mongod.conf

      # Start MongoDB
      systemctl enable mongod
      systemctl start mongod

      # Wait for MongoDB to start
      sleep 10

      # Create admin user
      mongo <<EOM
use admin
db.createUser({
  user: "admin",
  pwd: "securepassword",
  roles: [ { role: "root", db: "admin" } ]
})
EOM

      # Install AWS CLI
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install

      # Create backup script
      cat <<'EOM' > /usr/local/bin/mongo_backup.sh
#!/bin/bash
TIMESTAMP=$(date +%F-%H-%M)
BACKUP_DIR="/tmp/mongo-backup-$TIMESTAMP"
mkdir -p $BACKUP_DIR

mongodump --uri="mongodb://admin:securepassword@localhost:27017" --out=$BACKUP_DIR

aws s3 cp $BACKUP_DIR s3://shar-wiz-mongodb-backup/mongo-backups/$TIMESTAMP/ --recursive
rm -rf $BACKUP_DIR
EOM

      chmod +x /usr/local/bin/mongo_backup.sh

      # Schedule daily backup at 2 AM
      echo "0 2 * * * root /usr/local/bin/mongo_backup.sh" >> /etc/crontab
EOF

  tags = var.tags
}

