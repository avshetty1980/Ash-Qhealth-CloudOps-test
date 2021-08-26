# ---- networking/outputs.tf ----

output "vpc_id" {
  value = aws_vpc.ash_vpc.id
}

output "public_sg" {
  value = aws_security_group.ash_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.ash_public_subnet.*.id
}