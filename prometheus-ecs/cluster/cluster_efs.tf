# #---------------------------------------------------------------------------
# # Cluster EFS fyle system - the EFS will be mounted on each cluster instance
# #---------------------------------------------------------------------------
resource "aws_efs_file_system" "efs_file_system" {
  creation_token = "${var.name}-efs-token"
  tags {
    Name = "EFS ${var.name}"
  }
}
resource "aws_efs_mount_target" "efs_smount_target" {
  count           = "${length(var.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.efs_file_system.id}"
  subnet_id       = "${element(var.private_subnets, count.index)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
resource "aws_security_group" "efs_sg" {
  name        = "${var.name}-efs-sg"
  description = "Allow NFS-traffic with ${var.name} cluster"
  vpc_id      = "${var.vpc_id}"
  # inbound rules
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.asg_security_group.id}"]
  }
  # outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.name}-efs-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

