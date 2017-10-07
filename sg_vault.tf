resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Ports used by vault"

  tags {
    Name        = "vault"
    Description = "Ports used by vault"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "vault_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.vault.id}"
}

resource "aws_security_group_rule" "vault_tcp" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.vault.id}"
}

resource "aws_security_group_rule" "vault_server_tcp" {
  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.vault.id}"
}
