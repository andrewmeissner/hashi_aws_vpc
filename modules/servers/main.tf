data "template_file" "ignition_user_data" {
  count    = "${var.num_servers}"
  template = "${data.ignition_config.servers_config.rendered}"

  vars {
    consul_name = "${format("%s-%d", var.consul_name, count.index+1)}"
    nomad_name  = "${format("%s-%d", var.nomad_name, count.index+1)}"
    vault_name  = "${format("%s-%d", var.vault_name, count.index+1)}"
  }
}

resource "aws_instance" "server" {
  count                       = "${var.num_servers}"
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${var.security_group_ids}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  subnet_id                   = "${element(var.possible_subnets, count.index)}"
  iam_instance_profile        = "${var.iam_profile}"
  user_data                   = "${element(data.template_file.ignition_user_data.*.rendered, count.index)}"
  tags                        = "${merge(var.tags, map("Name", format("%s%s%s", var.consul_name, var.num_servers > 1 ? "-" : "", var.num_servers > 1 ? "${count.index+1}" : "")))}"
}

resource "aws_lb" "consul_lb" {
  name               = "consul-terraform-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.possible_subnets}"]

  tags {
    Name      = "consul-terraform-lb"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "consul_tg" {
  name     = "consul-tg"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/ui/"
    port                = 8500
    protocol            = "HTTP"
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    matcher             = 200
  }

  tags {
    Name      = "consul-terraform-tg"
    Terraform = "true"
  }
}

resource "aws_lb_target_group_attachment" "consul_tga" {
  count            = "${var.num_servers}"
  target_group_arn = "${aws_lb_target_group.consul_tg.arn}"
  target_id        = "${element(aws_instance.server.*.id, count.index)}"
  port             = 8500
}

resource "aws_lb_listener" "consul_listener" {
  load_balancer_arn = "${aws_lb.consul_lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.consul_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "consul_ns" {
  zone_id = "${var.r53_zone_id}"
  name    = "consul"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_lb.consul_lb.dns_name}"]
}

resource "aws_lb" "nomad_lb" {
  name               = "nomad-terraform-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.possible_subnets}"]

  tags {
    Name      = "nomad-terraform-lb"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "nomad_tg" {
  name     = "nomad-tg"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/ui/"
    port                = 4646
    protocol            = "HTTP"
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    matcher             = 200
  }

  tags {
    Name      = "nomad-terraform-tg"
    Terraform = "true"
  }
}

resource "aws_lb_target_group_attachment" "nomad_tga" {
  count            = "${var.num_servers}"
  target_group_arn = "${aws_lb_target_group.nomad_tg.arn}"
  target_id        = "${element(aws_instance.server.*.id, count.index)}"
  port             = 4646
}

resource "aws_lb_listener" "nomad_listener" {
  load_balancer_arn = "${aws_lb.nomad_lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.nomad_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "nomad_ns" {
  zone_id = "${var.r53_zone_id}"
  name    = "nomad"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_lb.nomad_lb.dns_name}"]
}

resource "aws_lb" "vault_lb" {
  name               = "vault-terraform-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.possible_subnets}"]

  tags {
    Name      = "vault-terraform-lb"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "vault_tg" {
  name     = "vault-tg"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/v1/sys/health"
    port                = 8200
    protocol            = "HTTP"
    interval            = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    matcher             = 200
  }

  tags {
    Name      = "vault-terraform-tg"
    Terraform = "true"
  }
}

resource "aws_lb_target_group_attachment" "vault_tga" {
  count            = "${var.num_servers}"
  target_group_arn = "${aws_lb_target_group.vault_tg.arn}"
  target_id        = "${element(aws_instance.server.*.id, count.index)}"
  port             = 8200
}

resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = "${aws_lb.vault_lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.vault_tg.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "vault_ns" {
  zone_id = "${var.r53_zone_id}"
  name    = "vault"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_lb.vault_lb.dns_name}"]
}
