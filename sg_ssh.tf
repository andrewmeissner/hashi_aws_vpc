resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allows ssh access"

  tags {
    Name        = "ssh"
    Description = "Allows ssh access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "ssh_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ssh.id}"
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ssh.id}"
}
