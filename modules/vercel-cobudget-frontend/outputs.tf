output "frontend_url" {
  description = "URL of the frontend app"
  value       = "https://${vercel_project_domain.frontend.domain}"
}