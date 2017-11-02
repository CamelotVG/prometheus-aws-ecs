#Cluster configuration
variable "name" {}

variable "cluster_min_size" {}
variable "cluster_max_size" {}
variable "key_name" {}
variable "vpc_id" {}

variable "private_subnets" {
  type = "list"
}

variable "instance_type" {}

variable "region" {}

#Bucket configuration
variable "config_bucket" {}

#Prometheus parameters

variable "prometheus" {
  type = "map"

  default = {
    name = "prometheus"
    port = "9090"
  }
}

#cAdvisor parameters
variable "cadvisor" {
  type = "map"

  default = {
    name               = "cAdvisor"
    port               = "8080"
    scraping_tag_key   = "Prometheus"
    scraping_tag_value = "cadvisor"
  }
}
