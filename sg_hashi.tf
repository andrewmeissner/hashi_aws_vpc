resource "aws_security_group" "hashi" {
  name        = "hashi"
  description = "Ports used by hashi"

  tags {
    Name        = "hashi"
    Description = "Ports used by hashi products"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "hashi_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "nomad_http_api" {
  type              = "ingress"
  from_port         = 4646
  to_port           = 4646
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "nomad_rpc" {
  type              = "ingress"
  from_port         = 4647
  to_port           = 4647
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "nomad_serf_wan_tcp" {
  type              = "ingress"
  from_port         = 4648
  to_port           = 4648
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "nomad_serf_wan_udp" {
  type              = "ingress"
  from_port         = 4648
  to_port           = 4648
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "vault_tcp" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "vault_server_tcp" {
  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_rpc" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_tcp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_serf_lan_udp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_serf_wan_tcp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_serf_wan_udp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_cli_rpc" {
  type              = "ingress"
  from_port         = 8400
  to_port           = 8400
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_http_api" {
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_dns_interface_tcp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}

resource "aws_security_group_rule" "consul_dns_interface_udp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.hashi.id}"
}
