output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.app_vpc.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.app_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}