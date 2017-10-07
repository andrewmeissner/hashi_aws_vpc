resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "Allows mysql access"

  tags {
    Name        = "mysql"
    Description = "Allows mysql access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "mysql_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mysql.id}"
}

resource "aws_security_group_rule" "mysql_http" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mysql.id}"
}
