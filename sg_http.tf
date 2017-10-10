resource "aws_security_group" "http" {
  name        = "http"
  description = "Allows http access"

  tags {
    Name        = "http"
    Description = "Allows http access"
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "http_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.http.id}"
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.http.id}"
}
