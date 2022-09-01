variable "redirect_uris" {
  description = "URI to redirect after successful authentication"
  type        = list(string)
}

variable "post_logout_redirect_uris" {
  description = "URI to redirect after logout"
  type        = list(string)
}

variable "logo_path" {
  description = "Path to logo for app"
  type        = string
}
