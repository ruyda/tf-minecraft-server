variable "server_name" {
  type        = string
  description = "the name to assign to deployed resources"
}

variable "existing_vpc_id" {
  type        = string
  nullable    = true
  description = "the ID of an existing VPC to associate the server instance with; if null, a VPC is created"
}

variable "existing_public_subnet_id" {
  type        = string
  nullable    = true
  description = "the ID of an existing public VPC subnet to run the server instance in; required if `existing_vpc_id` is provided"
}

variable "availability_zone" {
  type        = string
  default     = "us-east-2"
  description = "the availability zone of the existing or newly created private subnet"
}

variable "domain_zone_id" {
  type       = string
  nullable   = true
  description = "a Route 53 hosted zone ID to manage routing traffic to the server"
}

variable "domain" {
  type        = string
  nullable    = true
  description = "a Route 53 registered domain to use as a server URL; example: `mc.domain.com`; required if `domain_zone_id` is provided"
}

variable "ec2_instance_class" {
  type        = string
  default     = "t4g.small" # t4g.small for cost, t4g.medium for optimal gameplay
  description = "the instance class to assign the EC2 instance running the server"
}

variable "ssh_keypair_name" {
  type        = string
  nullable    = true
  description = "the name of the EC2 keypair to associate with the instance; required to enable SSH connections"
}

variable "ssh_ip_whitelist" {
  type        = list(string)
  default     = []
  description = "the list of user IP CIDRs to enable SSH (:22) access to the server EC2 instance; requires a value provided for `ssh-keypair_name`"
}

variable "player_ip_whitelist" {
  type        = list(string)
  default     = []
  description = "the list of player IP CIDRs to enable Minecraft connection to the server; if left empty anyone can connect from Minecraft"
}

variable "minecraft_server_jar_url" {
  type        = string
  default     = "https://piston-data.mojang.com/v1/objects/95495a7f485eedd84ce928cef5e223b757d2f764/server.jar" # 1.21.10
  description = "the URL where your Minecraft server JAR file can be downloaded"
}

variable "server_max_memory" {
  type        = string
  default     = "1300M"
  description = "the value passed to `-Xmx` flag when starting server.jar; cannot exceed the EC2 instance class memory"
}

variable "server_initial_memory" {
  type        = string
  default     = "1300M"
  description = "the value passed to `-Xms` flag when starting server.jar; cannot exceed the EC2 instance class memory"
}