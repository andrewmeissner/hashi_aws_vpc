resource "aws_lb" "registry_lb" {
  name               = "registry-terraform-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ssh.id}", "${aws_security_group.hashi.id}", "${aws_security_group.registry.id}", "${aws_security_group.http.id}"]
  subnets            = ["${module.vpc.private_subnets}"]

  tags {
    Name      = "registry-terraform-lb"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "registry_tg" {
  name     = "registry-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check {
    path                = "/"
    port                = 5000
    protocol            = "HTTP"
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    matcher             = 200
  }

  tags {
    Name      = "registry-terraform-tg"
    Terraform = "true"
  }
}

resource "aws_lb_listener" "registry_listener" {
  load_balancer_arn = "${aws_lb.registry_lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.registry_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "registry_ns" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "registry"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_lb.registry_lb.dns_name}"]
}
