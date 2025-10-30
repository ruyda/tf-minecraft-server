output "server_url" {
  value       = var.domain_zone_id == null ? aws_instance.server_instance.public_ip : var.domain
  description = "the public IP or domain used to connect to the Minecraft server"
}