variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "cluster_name" {
  description = "app cluster name"
}
variable "family_name" {
  description = "name of family of cluster"
  
}
variable "app_service" {
  description = "service name of the app"
  
}
variable "container_name" {
  description = "name of the container"
  
}
variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

