resource "aws_ebs_volume" "server_storage" {
  availability_zone = var.availability_zone
  size              = 8
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  tags = {
    Name = "${var.server_name}-storage"
  }
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

resource "aws_instance" "server_instance" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = var.ec2_instance_class # default t4g.small; suggested t4g.medium
  subnet_id     = var.existing_public_subnet_id == null ? aws_subnet.public_subnet[0].id : var.existing_public_subnet_id
  private_ip    = "10.0.0.12"
  key_name      = var.ssh_keypair_name

  user_data     = templatefile("${path.module}/initialize_server.sh", {
    minecraft_server_jar_url = "${var.minecraft_server_jar_url}",
    server_max_memory        = "${var.server_max_memory}"
    server_intial_memory     = "${var.server_initial_memory}"
  })

  tags = {
    Name = "${var.server_name}-server"
  }
}

resource "aws_volume_attachment" "server_storage_attachment" {
  device_name = "/dev/xvda" # TODO: understand why /dev/xvda...
  volume_id   = aws_ebs_volume.server_storage.id
  instance_id = aws_instance.server_instance.id
}