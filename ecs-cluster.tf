# --------------------------------------------
# Creates an ECS cluster with the following features:
#  * Prometheus,cAvisor service
#  * EFS
#  * CloudWatch alarms
#  * Configuration bucket
# -----------------------------------------
module "prometheus-ecs" {
  source = "../../modules/prometheus-ecs/cluster"

  name             = "ecs-prometheus"
  cluster_min_size = 2
  cluster_max_size = 6
  vpc_id           = ""
  private_subnets  = ""
  key_name         = ""
  instance_type    = "t2.micro"
  region           = ""
  config_bucket    = ""
}

output "dns_prometheus" {
  value = "${module.prometheus-ecs.dns_prometheus}"
}
