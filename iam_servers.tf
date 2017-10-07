resource "aws_iam_instance_profile" "servers" {
  name = "hashi-server"
  role = "${aws_iam_role.hashi_servers.name}"
}

resource "aws_iam_role_policy_attachment" "hashi_readonly" {
  role       = "${aws_iam_role.hashi_servers.name}"
  policy_arn = "${aws_iam_policy.ec2readonly.arn}"
}

resource "aws_iam_role" "hashi_servers" {
  name               = "hashi_servers_role"
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role_policy.json}"
}

resource "aws_iam_policy" "ec2readonly" {
  name        = "ec2readonly"
  description = "Read Only access in EC2"
  policy      = "${data.aws_iam_policy_document.ec2readonly.json}"
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2readonly" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    actions   = ["elasticloadbalancing:Describe*"]
    resources = ["*"]
  }

  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    actions   = ["autoscaling:Describe*"]
    resources = ["*"]
  }
}
