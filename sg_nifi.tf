resource "aws_security_group" "nifi" {
  name        = "nifi"
  description = "Allows nifi access"

  tags {
    Name        = "nifi"
    Description = "Allows nifi access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "nifi_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nifi.id}"
}

resource "aws_security_group_rule" "nifi_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nifi.id}"
}

resource "aws_security_group_rule" "nifi_listeners" {
  type              = "ingress"
  from_port         = 10000
  to_port           = 20000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nifi.id}"
}
