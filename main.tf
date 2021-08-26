# ---- root/main.tf ----

module "networking" {
  source             = "./networking"
  vpc_cidr           = local.vpc_cidr
  access_ip          = var.access_ip
  security_groups    = local.security_groups
  public_snet_count  = 2
  # private_snet_count = 3
  public_cidrs       = ["10.123.2.0/24", "10.123.4.0/24"]
  # private_cidrs      = ["10.123.1.0/24", "10.123.3.0/24", "10.123.5.0/24"]
  max_subnets        = 20
}

module "loadbalancing" {
  source                 = "./loadbalancing"
  public_sg              = module.networking.public_sg
  public_subnets         = module.networking.public_subnets
  tg_port                = 8000
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
}

module "compute" {
  source              = "./compute"
  instance_count      = 2
  instance_type       = "t2.micro"
  public_sg           = module.networking.public_sg
  public_subnets      = module.networking.public_subnets
  vol_size            = "10"
  key_name            = "ashkey"
  public_key_path     = "/home/ubuntu/.ssh/keyash.pub"
  user_data_path      = "${path.root}/userdata.tpl"
  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
}
