resource "aws_ecr_repository" "my_ecr_repository" {
  name = var.ecr_repo_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.my_ecr_repository.name

  policy = jsonencode({
    "rules": [
      {
        "rulePriority": 1,
        "description": "keep last 10 images",
        "action": {
          "type": "expire"
        },
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 4
        }
      }
    ]
  })
}

# Output the repository URI to a file
resource "null_resource" "output_repository_uri" {
  # Use a local-exec provisioner to write the repository URI to a file
  provisioner "local-exec" {
    command = "echo '${aws_ecr_repository.my_ecr_repository.repository_url}' > repository_uri.txt"
  }

  # This resource should only be executed after the ECR repository is created
  depends_on = [aws_ecr_repository.my_ecr_repository]
}
