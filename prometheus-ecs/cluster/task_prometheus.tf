#TODO: improve container configuration
resource "aws_ecs_task_definition" "prometheus" {
  family                = "${var.prometheus["name"]}"
  network_mode          = "host"
  container_definitions = "${file("${path.module}/files/task_prometheus.json")}"
  volume {
    name      = "prometheus"
    host_path = "/etc/prometheus"
  }
}
resource "aws_ecs_service" "prometheus" {
  name            = "${var.prometheus["name"]}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.prometheus.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.service_role.arn}"

  placement_strategy {
    type  = "spread"
    field = "host"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.prometheus.arn}"
    container_name   = "${var.prometheus["name"]}"
    container_port   = "${var.prometheus["port"]}"
  }

  depends_on = ["aws_ecs_cluster.cluster"]
}

resource "aws_alb_target_group" "prometheus" {
  name     = "${var.name}"
  port     = "${var.prometheus["port"]}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
      interval = 30
      path = "/graph"
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
  }
}

resource "aws_alb" "prometheus" {
  name            = "${var.name}-${var.prometheus["name"]}-alb"
  internal        = true
  security_groups = ["${aws_security_group.prometheus.id}"]
  subnets         = ["${var.private_subnets}"]
}

resource "aws_alb_listener" "prometheus" {
  load_balancer_arn = "${aws_alb.prometheus.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.prometheus.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "prometheus" {
  name        = "${var.name}-${var.prometheus["name"]}-alb"
  description = "${var.name}-${var.prometheus["name"]}-alb Security Group"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.name}-${var.prometheus["name"]}-alb"
  }
}
resource "aws_security_group_rule" "outbound" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "inbound" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}

