resource "aws_vpc" "server_vpc" {
  count      = var.existing_vpc_id == null ? 1 : 0
  cidr_block = "10.0.0.0/16"

  tags = {
    Name =  "${var.server_name}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  count  = var.existing_vpc_id == null ? 1 : 0
  vpc_id = aws_vpc.server_vpc[0].id
}

resource "aws_subnet" "public_subnet" {
  count                   = var.existing_vpc_id == null && var.existing_public_subnet_id == null ? 1 : 0
  vpc_id                  = aws_vpc.server_vpc[0].id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  depends_on = [ aws_internet_gateway.gateway ]

  tags = {
    Name = "${var.server_name}-private-subnet"
  }
}

resource "aws_security_group" "firewall" {
  name        = "${var.server_name}-firewall"
  description = "Control traffic in/out of Minecraft server EC2 instance"
  vpc_id      = var.existing_vpc_id == null ? aws_vpc.server_vpc[0].id : var.existing_vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "any_minecraft_connections" {
  count             = length(var.player_ip_whitelist) == 0 ? 1 : 0
  security_group_id = aws_security_group.firewall.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 25565
  to_port           = 25565
  description       = "Permit all user connections from Minecraft"
}

resource "aws_vpc_security_group_ingress_rule" "only_player_connections" {
  for_each          = length(var.player_ip_whitelist) == 0 ? [] : toset(var.player_ip_whitelist)
  security_group_id = aws_security_group.firewall.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 25565
  to_port           = 25565
  description       = "Permit player IP connections from Minecraft"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_connections" {
  for_each          = var.ssh_keypair_name == null ? [] : toset(var.ssh_ip_whitelist)
  security_group_id = aws_security_group.firewall.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Permit user IP connection over SSH"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.firewall.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_eip" "server_ip" {
  domain                    = "vpc"
  instance                  = aws_instance.server_instance.id
  associate_with_private_ip = aws_instance.server_instance.private_ip
  depends_on                = [ aws_internet_gateway.gateway ]

  tags = {
    Name = "${var.server_name}-ip"
  }
}

resource "aws_route53_record" "subdomain_route" {
  count   = var.domain_zone_id == null ? 0 : 1
  zone_id = var.domain_zone_id
  name    = var.domain
  type    = "A"
  ttl     = 60
  records = [ aws_instance.server_instance.public_ip ]
}