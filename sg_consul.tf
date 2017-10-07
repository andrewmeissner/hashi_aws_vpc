resource "aws_security_group" "consul" {
  name        = "consul"
  description = "Ports used by consul"

  tags {
    Name        = "consul"
    Description = "Ports used by consul"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "consul_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_rpc" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_tcp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_udp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_serf_wan_tcp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_serf_wan_udp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_cli_rpc" {
  type              = "ingress"
  from_port         = 8400
  to_port           = 8400
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_http_api" {
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_dns_interface_tcp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}

resource "aws_security_group_rule" "consul_dns_interface_udp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.consul.id}"
}
