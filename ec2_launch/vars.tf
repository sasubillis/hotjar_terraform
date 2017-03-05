variable "aws_access_key" {
  type    = "string"
  default = "XXX"
}

variable "aws_secret_key" {
  type    = "string"
  default = "XXX"
}

variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "ami_id" {
  type    = "string"
  default = "ami-1ad4170c"
}

variable "ssh_key_name" {
  type    = "string"
  default = "sreenu"
}


variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
