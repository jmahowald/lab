
variable "environment" { }
variable "db_subnet_group_name" {  default = "dev-blue" }
variable "num_azs" {  default = "2" }
variable "aurora_password" { }
variable "instance_class" {  default = "db.t2.small" }
variable "identifier_prefix" {  default = "dev-blue" }
module "db_network" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/mysql-rds-network"
  subnet_ids = "${module.network.private_subnet_ids}"
  inbound_security_group_ids = "${module.network.all_sg_ids}"
  subnet_ids = "${data.terraform_remote_state.vpc_layer.private_subnet_ids}"
  inbound_security_group_ids = "${data.terraform_remote_state.vpc_layer.all_sg_ids}"
  environment = "${var.environment}"
  db_subnet_group_name = "${var.db_subnet_group_name}"
}


output "db_subnet_group_name" {
  value = "${module.db_network.db_subnet_group_name}"
} 

module "db" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/aurora"
  db_security_group = "${module.db_network.security_group_id}"
  db_subnet_group_name = "${module.db_network.db_subnet_group_name}"
  num_azs = "${var.num_azs}"
  aurora_password = "${var.aurora_password}"
  instance_class = "${var.instance_class}"
  identifier_prefix = "${var.identifier_prefix}"
}


output "database_address" {
  value = "${module.db.database_address}"
} 
output "rds_identifier" {
  value = "${module.db.rds_identifier}"
} 




data "terraform_remote_state" "vpc_layer" {
  backend="s3"
  config { 
    bucket = "terraform.infra.codedontlie.tech"
    key = "env:/dev-blue/basevpc/terraform.tfstate"
    region = "us-east-1" }
} 
