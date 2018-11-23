# Create RDS instance
resource "aws_db_instance" "mysql_db" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "${var.db_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  storage_type = "gp2"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet_group.name}"
  vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
  skip_final_snapshot = true

  provisioner "local-exec" {
    command = "sh ./create_env.sh ${aws_db_instance.mysql_db.endpoint} ${var.app_repo} ${var.app_name}"
  }

  tags {
    Name = "user-feedbacks-mysql-db"
  }
}

# Provision S3 bucket to store app Package
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "user-feedbacks-shavindra"
  acl    = "public-read"
}
resource "aws_s3_bucket_object" "s3_object" {
  key = "${var.app_name}.zip"
  bucket = "${aws_s3_bucket.s3_bucket.id}"
  source = "${var.app_name}.zip"
  depends_on = ["aws_db_instance.mysql_db"]
}

# Provision Elastic Beanstalk app 
resource "aws_elastic_beanstalk_application" "userfeedback-app" {
  name        = "userfeedback-app"
  description = "userfeedback app"
}

resource "aws_elastic_beanstalk_environment" "userfeedbackenv-app" {
  name                = "userfeedbackenv-app"
  application         = "${aws_elastic_beanstalk_application.userfeedback-app.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.8.4 running PHP 7.0"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.vpc.id}"
  }

  # ELB Subnet
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.public_subnet.id}"
  }

  # Instance Subnet
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.public_subnet.id}"
  }

  # Enable Load Balancing for EB
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "MyKey"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name = "document_root"
    value = "${var.document_root}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }
}

resource "aws_elastic_beanstalk_application_version" "userfeedback-app" {
  name        = "user-feedbacks-app-version"
  application = "userfeedback-app"
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.s3_bucket.id}"
  key         = "${aws_s3_bucket_object.s3_object.id}"
}