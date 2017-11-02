# #--------------------------------------------------
# # Cloudwatch alarms for the prometheus ECS cluster
# #--------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.name}-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = ["${aws_autoscaling_policy.increase_capacity.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs.name}"
  }

  depends_on = ["aws_autoscaling_group.ecs", "aws_autoscaling_policy.increase_capacity"]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "${var.name}-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"
  alarm_actions       = ["${aws_autoscaling_policy.decrease_capacity.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs.name}"
  }

  depends_on = ["aws_autoscaling_group.ecs", "aws_autoscaling_policy.decrease_capacity"]
}
