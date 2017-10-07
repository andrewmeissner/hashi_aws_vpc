module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform"

  cidr = "172.34.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["172.34.1.0/26", "172.34.2.64/26", "172.34.3.128/26"]
  public_subnets  = ["172.34.101.0/26", "172.34.102.64/26", "172.34.103.128/26"]

  create_database_subnet_group = false

  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  map_public_ip_on_launch = true
  single_nat_gateway      = true

  tags {
    Name        = "terraform"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_main_route_table_association" "terraform_public_main" {
  vpc_id         = "${module.vpc.vpc_id}"
  route_table_id = "${element(module.vpc.public_route_table_ids, 0)}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name          = "service.consul"
  domain_name_servers  = ["127.0.0.1", "172.34.0.2"]
  ntp_servers          = ["127.0.0.1"]
  netbios_name_servers = ["127.0.0.1"]
  netbios_node_type    = 2

  tags {
    Name      = "terraform-dhcp"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${module.vpc.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("deploy.pub")}"
}
