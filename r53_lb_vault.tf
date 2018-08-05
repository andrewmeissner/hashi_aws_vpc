// resource "aws_lb" "vault_lb" {
//   name               = "vault-terraform-lb"
//   internal           = true
//   load_balancer_type = "application"
//   security_groups    = ["${aws_security_group.ssh.id}", "${aws_security_group.hashi.id}", "${aws_security_group.http.id}"]
//   subnets            = ["${module.vpc.private_subnets}"]

//   tags {
//     Name      = "vault-terraform-lb"
//     Terraform = "true"
//   }
// }

// resource "aws_lb_target_group" "vault_tg" {
//   name     = "vault-tg"
//   port     = 8200
//   protocol = "HTTP"
//   vpc_id   = "${module.vpc.vpc_id}"

//   health_check {
//     path                = "/v1/sys/health"
//     port                = 8200
//     protocol            = "HTTP"
//     interval            = 5
//     healthy_threshold   = 2
//     unhealthy_threshold = 2
//     timeout             = 2
//     matcher             = 200
//   }

//   tags {
//     Name      = "vault-terraform-tg"
//     Terraform = "true"
//   }
// }

// resource "aws_lb_listener" "vault_listener" {
//   load_balancer_arn = "${aws_lb.vault_lb.arn}"
//   port              = 80
//   protocol          = "HTTP"

//   default_action {
//     target_group_arn = "${aws_lb_target_group.vault_tg.arn}"
//     type             = "forward"
//   }
// }

// resource "aws_route53_record" "vault_ns" {
//   zone_id = "${aws_route53_zone.private.zone_id}"
//   name    = "vault"
//   ttl     = 300
//   type    = "CNAME"
//   records = ["${aws_lb.vault_lb.dns_name}"]
// }
