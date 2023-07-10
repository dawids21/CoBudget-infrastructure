variable "registry_username" {
  description = "Username for the private registry"
  type        = string
  sensitive   = true
}

variable "registry_password" {
  description = "Password for the private registry"
  type        = string
  sensitive   = true
}