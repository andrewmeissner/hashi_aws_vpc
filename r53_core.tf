resource "aws_route53_zone" "private" {
  name          = "core.com"
  vpc_id        = "${module.vpc.vpc_id}"
  vpc_region    = "${var.region}"
  force_destroy = true

  tags {
    Name      = "private_zone"
    Terraform = "true"
  }
}
