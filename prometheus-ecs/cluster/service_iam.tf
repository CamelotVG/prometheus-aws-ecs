# service role
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = "${var.name}-container-service"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  role       = "${aws_iam_role.service_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# Cluster scraping role 
resource "aws_iam_role" "scraping_role" {
  name               = "${var.name}-scraping"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.scraping_role_assume.json}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "scraping_role_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "scraping_role_policy" {
  role       = "${aws_iam_role.scraping_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
