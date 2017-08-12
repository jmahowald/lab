
variable "availability_zone_count" {  default = "3" }
variable "aws_region" {  default = "us-east-1" }
variable "environment" {  default = "dev-blue" }
variable "owner" {  default = "&lt;no value&gt;" }
variable "vpc_cidr" {  default = "10.100.0.0/16" }
variable "public_subnet_cidrs" {  
  type="list" 
  default = [ 
    "10.100.0.0/24", 
    "10.100.1.0/24", 
    "10.100.2.0/24",
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
  
module "network" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/network"
  ami = "${module.amazon-amis.ami_id}"
  image_user = "${module.amazon-amis.image_user}"
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
output "public_sg_id" {
  value = "${module.network.public_sg_id}"
} 
output "availabity_zones" {
  value = "${module.network.availabity_zones}"
} 
output "public_cidrs" {
  value = "${module.network.public_cidrs}"
} 

module "amazon-amis" {
  source = "/Users/josh/workspace/projects/terraform/terraform-aws-vpc//modules/amazon-amis"
}






