# #--------------------------------------------------
# # Cluster security group
# #--------------------------------------------------
resource "aws_security_group" "asg_security_group" {
  name        = "${var.name}-sg"
  description = "Allow all local traffic"
  vpc_id      = "${var.vpc_id}"
  # inbound rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  # outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.name}-sg"
  }
}

