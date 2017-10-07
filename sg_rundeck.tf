resource "aws_security_group" "rundeck" {
  name        = "rundeck"
  description = "Allows rundeck access"

  tags {
    Name        = "rundeck"
    Description = "Allows rundeck access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "rundeck_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.rundeck.id}"
}

resource "aws_security_group_rule" "rundeck_http" {
  type              = "ingress"
  from_port         = 4440
  to_port           = 4440
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.rundeck.id}"
}
