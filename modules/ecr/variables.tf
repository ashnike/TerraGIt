variable "ecr_repo_name" {
  description = "ecr repo name"
}
variable "scan_on_push" {
  type = bool
  description = "(Required) Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  default = true
}
variable "image_tag_mutability" {
  type = string
  description = "(Optional) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE"
  default = "MUTABLE"
}