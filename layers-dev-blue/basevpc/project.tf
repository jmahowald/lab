
variable "key_name" { }
variable "availability_zone_count" {  default = "2" }
variable "aws_region" {  default = "us-east-1" }
variable "environment" {  default = "dev-blue" }
variable "owner" {  default = "josh" }
variable "vpc_cidr" {  default = "10.100.0.0/16" }
variable "public_subnet_cidrs" {  
  type="list" 
  default = [ 
    "10.100.0.0/24", 
    "10.100.1.0/24",
  ]
}
  
variable "private_subnet_cidrs" {  
  type="list" 
  default = [ 
    "10.100.10.0/24", 
    "10.100.11.0/24", 
    "10.100.12.0/24",
  ]
}
  
variable "key_dir" { }
variable "zone_name" { }
variable "autoscaling_group_name" {  default = "tf-ecs-dev-blue" }
module "network" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/network"
  ssh_keypath = "${module.sshkey.key_path}"
  ami = "${module.amazon-amis.ami_id}"
  image_user = "${module.amazon-amis.image_user}"
  key_name = "${var.key_name}"
  availability_zone_count = "${var.availability_zone_count}"
  aws_region = "${var.aws_region}"
  environment = "${var.environment}"
  owner = "${var.owner}"
  vpc_cidr = "${var.vpc_cidr}"
  public_subnet_cidrs = "${var.public_subnet_cidrs}"
  private_subnet_cidrs = "${var.private_subnet_cidrs}"
}


output "vpc_id" {
  value = "${module.network.vpc_id}"
} 
output "vpc_cidr" {
  value = "${module.network.vpc_cidr}"
} 
output "public_subnet_ids" {
  value = "${module.network.public_subnet_ids}"
} 
output "private_subnet_ids" {
  value = "${module.network.private_subnet_ids}"
} 
output "all_sg_ids" {
  value = "${module.network.all_sg_ids}"
} 
output "public_sg_id" {
  value = "${module.network.public_sg_id}"
} 
output "availabity_zones" {
  value = "${module.network.availabity_zones}"
} 

module "amazon-amis" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/amazon-amis"
}



module "sshkey" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/keys/keygen"
  key_dir = "${var.key_dir}"
  key_name = "${var.key_name}"
}



module "awskey" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/keys"
  public_key = "${module.sshkey.public_key}"
  key_name = "${var.key_name}"
}



module "ecs_infra" {
  source = "/Users/josh/workspace/projects/lab/terraform-ecs/terraform-ecs-modules//infrastructure"
  public_security_group_id = "${module.network.public_sg_id}"
  private_security_group_id = "${module.network.private_sg_id}"
  environment = "${var.environment}"
}


output "ecs_role_arn" {
  value = "${module.ecs_infra.ecs_role_arn}"
} 

module "ecs" {
  source = "/Users/josh/workspace/projects/lab/terraform-ecs/terraform-ecs-modules//cluster"
  ecs_role_arn = "${module.ecs_infra.ecs_role_arn}"
  elb_subnet_ids = "${module.network.public_subnet_ids}"
  asg_subnet_ids = "${module.network.private_subnet_ids}"
  instance_security_group_id = "${module.network.private_sg_id}"
  private_subnet_ids = "${module.network.private_subnet_ids}"
  public_subnet_ids = "${module.network.public_subnet_ids}"
  public_security_group_id = "${module.network.public_sg_id}"
  private_security_group_id = "${module.network.private_sg_id}"
  key_name = "${var.key_name}"
  environment = "${var.environment}"
  zone_name = "${var.zone_name}"
  environment = "${var.environment}"
  autoscaling_group_name = "${var.autoscaling_group_name}"
}


output "cluster_id" {
  value = "${module.ecs.cluster_id}"
} 
output "public_listener_arns" {
  value = "${module.ecs.public_listener_arns}"
} 
output "asg_name" {
  value = "${module.ecs.asg_name}"
} 
output "cloudwatch_log_group_prefix" {
  value = "${module.ecs.cloudwatch_log_group_prefix}"
} 




