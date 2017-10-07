module "openvpnas" {
  source = "./modules/aws_instance"

  name                        = "OpenVPN-AS"
  ami                         = "ami-e346559a"
  key_name                    = "${aws_key_pair.deployer.key_name}"
  possible_subnets            = ["${module.vpc.public_subnets}"]
  security_group_ids          = ["${aws_security_group.ssh.id}", "${aws_security_group.openvpn.id}"]
  region                      = "${var.region}"
  associate_public_ip_address = true

  user_data = <<EOF
      admin_pw=${var.openvpn_pw}
      reroute_gw=0
      reroute_dns=0
    EOF

  tags {
    Terraform = "true"
  }
}

output "OpenVPN_IP" {
  description = "The public IP of the openvpn-as server"
  value       = "${module.openvpnas.public_ip}"
}
