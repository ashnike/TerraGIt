terraform {
  backend "s3" {
    bucket         = "jenkasbucket"
    key            = "folder/statefile.tfstate"
    region         = "us-east-1"
    dynamodb_table = "Jenkaftable"
    encrypt        = true
  }
}
