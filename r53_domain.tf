resource "aws_route53_zone" "private" {
  name          = "${var.domain}"
  force_destroy = true

  vpc {
    vpc_id     = "${module.vpc.vpc_id}"
    vpc_region = "${var.region}"
  }

  tags {
    Name      = "private_zone"
    Terraform = "true"
  }
}
