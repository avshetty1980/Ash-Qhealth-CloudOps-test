# ---- compute/main.tf ----

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*.2-x86_64-gp2"]
  }
}

resource "random_id" "ash_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name # to force change of instance id when key pair changes
  }
}

resource "aws_key_pair" "ash_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "ash_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id

  tags = {
    Name = "ash_node-${random_id.ash_node_id[count.index].dec}"
  }

  key_name = aws_key_pair.ash_auth.id

  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile(var.user_data_path,
    {
      nodename = "ash-${random_id.ash_node_id[count.index].dec}"

    }
  )

  root_block_device {
    volume_size = var.vol_size

  }

}

resource "aws_lb_target_group_attachment" "ash_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.ash_node[count.index].id
  port             = 8000
}