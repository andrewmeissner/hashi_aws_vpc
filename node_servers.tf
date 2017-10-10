module "core_servers" {
  source = "./modules/servers"

  num_servers          = 3
  consul_name          = "consul"
  nomad_name           = "nomad"
  ami                  = "${var.ami_id}"
  instance_type        = "t2.micro"
  region               = "${var.region}"
  possible_subnets     = ["${module.vpc.private_subnets}"]
  security_group_ids   = ["${aws_security_group.ssh.id}", "${aws_security_group.consul.id}", "${aws_security_group.nomad.id}", "${aws_security_group.vault.id}", "${aws_security_group.http.id}"]
  key_name             = "${aws_key_pair.deployer.key_name}"
  iam_profile          = "${aws_iam_instance_profile.servers.name}"
  ignition_user_ids    = ["${data.ignition_user.ameissner.id}"]
  ignition_group_ids   = ["${data.ignition_group.ameissner.id}"]
  ignition_systemd_ids = ["${data.ignition_systemd_unit.docker_tcp_socket.id}"]
  ignition_file_ids    = ["${data.ignition_file.etc_resolv.id}"]
  r53_zone_id          = "${aws_route53_zone.private.zone_id}"

  tags {
    Terraform     = "true"
    Consul-Server = "true"
  }
}

output "core_server_ips" {
  value = "${module.core_servers.server_ips}"
}
