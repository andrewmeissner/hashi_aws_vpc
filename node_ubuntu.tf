module "single_ubuntu" {
  source = "./modules/aws_instance"

  name               = "myubuntu"
  num_nodes          = 0
  ami                = "ami-0bbe6b35405ecebdb"
  key_name           = "${aws_key_pair.deployer.key_name}"
  possible_subnets   = ["${module.vpc.private_subnets}"]
  security_group_ids = ["${aws_security_group.ssh.id}"]
  region             = "${var.region}"
  instance_type      = "r4.4xlarge"
  volume_type        = "gp2"
  volume_size        = 160

  tags {
    Terraform = "true"
  }
}

output "ubuntu_ip" {
  description = "The private IP of the single ubuntu instance"
  value       = "${module.single_ubuntu.private_ips}"
}
