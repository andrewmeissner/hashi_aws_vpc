resource "aws_security_group" "registry" {
  name        = "registry"
  description = "Allows registry access"

  tags {
    Name        = "registry"
    Description = "Allows registry access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "registry_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.registry.id}"
}

resource "aws_security_group_rule" "registry" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.registry.id}"
}
