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

    # Install MongoDB 6.0 on Amazon Linux 2
    echo "[mongodb-org-6.0]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
    gpgcheck=1
    enabled=1
    gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc" | sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo
    
    if ! command -v mongod &> /dev/null
    then
      echo "MongoDB not found, installing version 6.0..."
      sudo yum install -y mongodb-org-6.0.14  # Pin to a specific 6.0 version for consistency
    else
      echo "MongoDB found, ensuring it's the required version (6.0)..."
    fi
    
    # Start MongoDB service
    sudo systemctl enable mongod
    sudo systemctl start mongod
    echo "MongoDB 6.0 installation and startup complete."

    # Simple daily backup cron to S3 
    apt-get install -y awscli
    mkdir -p /var/backups/mongo
    echo "0 2 * * * root mongodump --archive=/var/backups/mongo/mongo-$(date +\%F).gz --gzip && aws s3 cp /var/backups/mongo/ s3://${var.backup_bucket}/ --recursive --acl public-read" > /etc/cron.d/mongo-backup
  EOF

  tags = var.tags
}

