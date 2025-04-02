variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "aws_security_group_name" {
  description = "Security group name"
  type        = string
}

variable "aws_subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "aws_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ec2_host" {
  description = "EC2 host address"
  type        = string
}

variable "ec2_ssh_key" {
  description = "SSH key name for EC2 access"
  type        = string
}

variable "ec2_username" {
  description = "Username for EC2 SSH access"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB connection URI"
  type        = string
  sensitive   = true
}

variable "dockerhub_username" {
  description = "DockerHub username"
  type        = string
}

variable "dockerhub_token" {
  description = "DockerHub token"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_ips" {
  description = "CIDR block for allowed SSH access"
  type        = string
}