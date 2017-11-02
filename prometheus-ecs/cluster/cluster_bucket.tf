#--------------------------------------------------
# Bucket to store - config files
#--------------------------------------------------

resource "aws_s3_bucket" "bucket_config" {
  bucket = "${var.config_bucket}"
  acl    = "private"

  tags {
    Name = "${var.config_bucket}"
  }
}

# Prometheus configuration file
data "template_file" "prometheus_template" {
  template = "${file("${path.module}/files/prometheus.yml")}"

  vars {
    region                      = "${var.region}"
    prometheus_scraping_role    = "${aws_iam_role.scraping_role.arn}"
    prometheus_scraping_port    = "${var.prometheus["port"]}"
    cadvisor_job_name           = "${var.cadvisor["name"]}"
    cadvisor_scraping_port      = "${var.cadvisor["port"]}"
    cadvisor_scraping_tag_key   = "${var.cadvisor["scraping_tag_key"]}"
    cadvisor_scraping_tag_value = "${var.cadvisor["scraping_tag_value"]}"
  }

  depends_on = ["aws_iam_role.scraping_role"]
}

resource "aws_s3_bucket_object" "prometheus_file" {
  bucket  = "${aws_s3_bucket.bucket_config.id}"
  key     = "prometheus.yml"
  content = "${data.template_file.prometheus_template.rendered}"
}
