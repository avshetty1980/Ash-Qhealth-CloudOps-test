# --- networking/main.tf ----

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "public_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "ash_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ash_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "ash_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.ash_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.public_az.result[count.index] # data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ash_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "ash_public_assoc" {
  count          = var.public_snet_count
  subnet_id      = aws_subnet.ash_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.ash_public_rtb.id

}

# resource "aws_subnet" "ash_private_subnet" {
#   count                   = length(var.private_cidrs)
#   vpc_id                  = aws_vpc.ash_vpc.id
#   cidr_block              = var.private_cidrs[count.index]
#   map_public_ip_on_launch = false
#   availability_zone       = data.aws_availability_zones.available.names[count.index]

#   tags = {
#     Name = "ash_private_${count.index + 1}"
#   }

# }

resource "aws_internet_gateway" "ash_internet_gateway" {
  vpc_id = aws_vpc.ash_vpc.id

  tags = {
    Name = "ash_igw"
  }
}

resource "aws_route_table" "ash_public_rtb" {
  vpc_id = aws_vpc.ash_vpc.id

  tags = {
    Name = "ash_public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.ash_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ash_internet_gateway.id
}

# resource "aws_default_route_table" "ash_private_rtb" {
#   default_route_table_id = aws_vpc.ash_vpc.default_route_table_id

#   tags = {
#     Name = "ash_private"
#   }
# }

resource "aws_security_group" "ash_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.ash_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}