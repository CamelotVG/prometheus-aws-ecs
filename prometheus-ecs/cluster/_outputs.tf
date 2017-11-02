output "dns_prometheus" {
  value  ="${aws_alb.prometheus.dns_name}"
}