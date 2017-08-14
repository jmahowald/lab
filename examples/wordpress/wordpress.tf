
variable "service_name" {default = "blog"}
variable "priority" {default = 10}
variable "health_check" {
  default = [ 
    {
      path = "/wp-admin/install.php"
      interval = 300
    }

  ]
}


variable "vpc_id" {}
variable "listener_arn" {}
variable "cluster_name" {}
variable "ecs_arn" {}
variable "log_group_prefix" {}
variable "zone_name" {} 
output "log_group" {
  value = "${aws_cloudwatch_log_group.ecs.name}"
}
output "cluster_name" {
  value = "${var.cluster_name}"
}
output "ecs_arn" {
  value = "${var.ecs_arn}"
}
output "target_group_arn" {
  value = "${module.ecs_service.tg_arn}"
}


module "ecs_service" {
  health_check = "${var.health_check}"
  source = "github.com/jmahowald/terraform-ecs-modules//targetgroup"
  vpc_id = "${var.vpc_id}"
  listener_arn = "${var.listener_arn}"
  log_group_prefix = "${var.log_group_prefix}"
  priority = "${var.priority}"
  service_name = "${var.service_name}"
  hostnamerules =  ["${var.service_name}*${var.zone_name}"]
}


resource "aws_cloudwatch_log_group" "ecs" {
  name = "${var.log_group_prefix}${var.service_name}"
  retention_in_days = 30
}


