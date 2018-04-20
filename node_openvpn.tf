module "openvpnas" {
  source = "./modules/aws_instance"

  name                        = "OpenVPN-AS"
  ami                         = "ami-7370ed0b"
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

/******************************************************************************************
https://docs.openvpn.net/how-to-tutorialsguides/amazon-ec2-appliance-ami-quick-start-guide/

AWS parameters supplied as user-data
---------------------------------------------

Define as:

KEY1=VALUE1
KEY2=VALUE2
...

Do not quote keys or values or use spaces on either side
of the '=' character. All parameters are optional.

public_hostname -- hostname that clients should use to contact the server.

admin_user (default=openvpn) -- Access Server administrative account name.

admin_pw -- administrative account initial password. Note that
this parameter is communicated to the instance via a
cleartext channel. A more secure method would be to ssh
to the instance and use the passwd command to set the
password.

license -- Access Server license key (without a license key, the
Access Server will support up to 2 concurrent connections).

reroute_gw (boolean, default=0) -- if 1, clients will route internet
traffic through the VPN.

reroute_dns (boolean, default=0) -- if 1, clients will route DNS
queries through the VPN.

In addition, the VPC CIDR block (if defined) will be made accessible to
VPN clients via NAT.
******************************************************************************************/

