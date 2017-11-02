# #--------------------------------------------------
# # Cluster instances configuration
# #--------------------------------------------------

resource "aws_launch_configuration" "ecs" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix          = "terraform-${var.name}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  image_id             = "${data.aws_ami.ecs.image_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.asg_security_group.id}"]
  key_name             = "${var.key_name}"
  user_data            = "${data.template_file.user_data.rendered}"

  depends_on = ["aws_iam_instance_profile.instance_profile", "aws_security_group.asg_security_group"]
}

# EC2 cluster instances - booting script
data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  name_regex = "amzn-ami-\\d{4}.\\d{2}.\\w-amazon-ecs-optimized"
}

# EC2 cluster instances - booting script
data "template_file" "user_data" {
  template = "${file("${path.module}/files/user_data.sh.tpl")}"

  vars {
    ecs_name          = "${aws_ecs_cluster.cluster.name}"
    efs_id            = "${aws_efs_file_system.efs_file_system.id}"
    aws_region        = "${var.region}"
    efs_mount_point   = "/etc/prometheus"
    bucket_config     = "${aws_s3_bucket.bucket_config.id}"
    cadvisor_revision = "${aws_ecs_task_definition.cadvisor.family}:${aws_ecs_task_definition.cadvisor.revision}"
  }
}
