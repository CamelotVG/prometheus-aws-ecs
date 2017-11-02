#--------------------------------------------------
# Cluster IAM configuration
#--------------------------------------------------
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = "${aws_iam_role.cluster_role.name}"
}

# Role for the cluster instances
resource "aws_iam_role" "cluster_role" {
  name               = "${var.name}-instance-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.cluster_role_assume.json}"
}

data "aws_iam_policy_document" "cluster_role_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ECS EC2 managed policy
resource "aws_iam_role_policy_attachment" "cluster_role_managed_policy" {
  role       = "${aws_iam_role.cluster_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Bucket access and start cadvisor policy
resource "aws_iam_policy" "cluster_role_custom_policy" {
  name        = "${var.name}-instance-role-permissions"
  description = "Allows EC2 instances to access ${var.config_bucket} bucket and Start ECS tasks"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket_config.id}/*",
                "arn:aws:s3:::${aws_s3_bucket.bucket_config.id}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:StartTask"
            ],
            "Resource": "${aws_ecs_task_definition.cadvisor.arn}"
        },
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Resource": "${aws_iam_role.scraping_role.arn}"
        }
    ]
}
EOF

  depends_on = ["aws_iam_role.scraping_role", "aws_ecs_task_definition.cadvisor", "aws_s3_bucket.bucket_config"]
}

resource "aws_iam_role_policy_attachment" "cluster_role_custom_policy_attachment" {
  role       = "${aws_iam_role.cluster_role.id}"
  policy_arn = "${aws_iam_policy.cluster_role_custom_policy.arn}"
}
