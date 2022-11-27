module "networking" {
  source = "./modules/networking"
  region               = "${var.region}"
  env                  = "${var.env}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
}
module "ec2_instance" {
  source = "./modules/ec2_instance"
  region               = "${var.region}"
  env                  = "${var.env}"
  public_subnet       = "${module.networking.public_subnet}"
  private_subnet      = "${module.networking.private_subnet}"
  vpc_id              = "${module.networking.vpc_id}"
}


locals {
  production_availability_zones = [ "us-east-2a","us-east-2b", "us-east-2c"]
  region = "us-east-2"
}
