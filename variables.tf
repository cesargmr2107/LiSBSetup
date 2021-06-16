
/* LOGIN VARIABLES */

variable "aws_access_key" {
    type = string
    description = "Enter your AWS access key"
    default=""
}

variable "aws_secret_key" {
    type = string
    description = "Enter your AWS secret key"
    default=""
}

variable "aws_region" {
    type = string
    description = "Enter the AWS region in which you wish to work"
    default = ""
}

variable "aws_account_id" {
    type = string
    description = "The AWS account ID"
    default = ""
}

variable "sns_email" {
    type = string
    description = "Email used for SNS notifications"
    default = ""
}

/* SERVER INSTANCE VARIABLES */

variable "subnet_id" {
    type = string
    description = "Enter the subnet ID of the subnet in which to deploy VPN server"
    default = ""
}

variable "instance_type" {
    type = string
    description = "Enter the instance type for the VPN server instance"
    default = ""
}

variable "instance_ami" {
    type = string
    description = "The AMI that will be used for the instance creation"
    default = ""
}