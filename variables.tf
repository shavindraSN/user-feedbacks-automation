variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "MyKey"
}

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "s3_bucket" {}
variable "app_version" {}
variable "app_repo" {}
variable "app_name" {}

variable "deployment_policy" {
  type    = "string"
  default = "Rolling"
  description = "The deployment policy"
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.rolling-version-deploy.html?icmpid=docs_elasticbeanstalk_console
}
variable "document_root" {
  type    = "string"
  default = "/public"
  description = "Specify the child directory of your project that is treated as the public-facing web root."
}

variable "vpc_cidr" {
  description = "CIDR block for whole VPC"
  default = "10.1.0.0/16"
}
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default = "10.1.0.0/24"
}
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  default = "10.1.1.0/24"
}

variable "private_subnet2_cidr" {
  description = "CIDR block for private subnet"
  default = "10.1.2.0/24"
}