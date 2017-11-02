# #--------------------------------------------------
# # Cluster instances autoscaling policies
# #--------------------------------------------------
resource "aws_autoscaling_group" "ecs" {
  lifecycle {
    create_before_destroy = true
  }

  name                      = "${var.name}-${aws_launch_configuration.ecs.name}"
  min_size                  = "${var.cluster_min_size}"
  max_size                  = "${var.cluster_max_size}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier       = ["${var.private_subnets}"]
  termination_policies      = ["OldestInstance"]
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${var.name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "${var.cadvisor["scraping_tag_key"]}"
    value               = "${var.cadvisor["scraping_tag_value"]}"
    propagate_at_launch = true
  }

  depends_on = ["aws_launch_configuration.ecs"]
}

resource "aws_autoscaling_policy" "increase_capacity" {
  name                   = "${var.name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  depends_on = ["aws_autoscaling_group.ecs"]
}

resource "aws_autoscaling_policy" "decrease_capacity" {
  name                   = "${var.name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  depends_on = ["aws_autoscaling_group.ecs"]
}
