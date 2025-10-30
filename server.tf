data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

resource "aws_instance" "server_instance" {
  ami             = data.aws_ami.amzn-linux-2023-ami.id
  instance_type   = var.ec2_instance_class # default t4g.small; suggested t4g.medium
  subnet_id       = var.existing_public_subnet_id == null ? aws_subnet.public_subnet[0].id : var.existing_public_subnet_id
  key_name        = var.ssh_keypair_name
  security_groups = [ aws_security_group.firewall.id ]

  user_data     = templatefile("${path.module}/initialize_server.sh.tftpl", {
    minecraft_server_jar_url  = var.minecraft_server_jar_url,
    server_max_memory         = var.server_max_memory
    server_initial_memory     = var.server_initial_memory
  })

  tags = {
    Name = "${var.server_name}-server"
  }
}