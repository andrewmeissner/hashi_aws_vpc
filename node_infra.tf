module "infra_nodes" {
  source = "./modules/clients"

  min_clients               = 3
  max_clients               = 9
  desired_clients           = 3
  cluster_name              = "infra"
  ami                       = "${var.ami_id}"
  instance_type             = "t2.large"
  region                    = "${var.region}"
  availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}c"]
  subnet_ids                = ["${module.vpc.private_subnets}"]
  key_name                  = "${aws_key_pair.deployer.key_name}"
  security_group_ids        = ["${aws_security_group.ssh.id}", "${aws_security_group.consul.id}", "${aws_security_group.nomad.id}", "${aws_security_group.vault.id}", "${aws_security_group.rundeck.id}"]
  iam_instance_profile_name = "${aws_iam_instance_profile.servers.name}"
  ignition_user_ids         = ["${data.ignition_user.ameissner.id}"]
  ignition_group_ids        = ["${data.ignition_group.ameissner.id}"]
  ignition_systemd_ids      = ["${data.ignition_systemd_unit.docker_tcp_socket.id}"]
  ignition_file_ids         = ["${data.ignition_file.etc_resolv.id}"]
}
