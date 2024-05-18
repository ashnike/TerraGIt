variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)

}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
 
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
 
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
variable "ecr_repo_name" {
  description = "ecr repo name"
}
