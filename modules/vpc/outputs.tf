output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}
output "private_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.private_subnets[*].id
}
