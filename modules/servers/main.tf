data "template_file" "ignition_user_data" {
  count    = "${var.num_servers}"
  template = "${data.ignition_config.servers_config.rendered}"

  vars {
    consul_name = "${format("%s-%d", var.consul_name, count.index+1)}"
    nomad_name  = "${format("%s-%d", var.nomad_name, count.index+1)}"
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

resource "aws_elb" "consul_elb" {
  name            = "consul-terraform-elb"
  internal        = true
  subnets         = ["${var.possible_subnets}"]
  security_groups = ["${var.security_group_ids}"]

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8500/ui/"
    interval            = 15
  }

  tags {
    Name      = "consul-terraform-elb"
    Terraform = "true"
  }
}

resource "aws_elb" "nomad_elb" {
  name            = "nomad-terraform-elb"
  internal        = true
  subnets         = ["${var.possible_subnets}"]
  security_groups = ["${var.security_group_ids}"]

  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:4646/ui/"
    interval            = 15
  }

  tags {
    Name      = "nomad-terraform-elb"
    Terraform = "true"
  }
}

resource "aws_elb_attachment" "consul_nodes" {
  count    = "${var.num_servers}"
  elb      = "${aws_elb.consul_elb.id}"
  instance = "${element(aws_instance.server.*.id, count.index)}"
}

resource "aws_elb_attachment" "nomad_nodes" {
  count    = "${var.num_servers}"
  elb      = "${aws_elb.nomad_elb.id}"
  instance = "${element(aws_instance.server.*.id, count.index)}"
}

resource "aws_route53_record" "consul_ns" {
  zone_id = "${var.r53_zone_id}"
  name    = "consul"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_elb.consul_elb.dns_name}"]
}

resource "aws_route53_record" "nomad_ns" {
  zone_id = "${var.r53_zone_id}"
  name    = "nomad"
  ttl     = 300
  type    = "CNAME"
  records = ["${aws_elb.nomad_elb.dns_name}"]
}
