resource "aws_security_group" "nomad" {
  name        = "nomad"
  description = "Ports used by nomad"

  tags {
    Name        = "nomad"
    Description = "Ports used by nomad"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "nomad_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "nomad_http_api" {
  type              = "ingress"
  from_port         = 4646
  to_port           = 4646
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "nomad_rpc" {
  type              = "ingress"
  from_port         = 4647
  to_port           = 4647
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "nomad_serf_wan_tcp" {
  type              = "ingress"
  from_port         = 4648
  to_port           = 4648
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "nomad_serf_wan_udp" {
  type              = "ingress"
  from_port         = 4648
  to_port           = 4648
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nomad.id}"
}
