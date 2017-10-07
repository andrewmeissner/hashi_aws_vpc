module "app_nodes" {
  source = "./modules/clients"

  min_clients               = 6
  max_clients               = 12
  desired_clients           = 6
  cluster_name              = "app"
  ami                       = "${var.ami_id}"
  instance_type             = "t2.micro"
  region                    = "${var.region}"
  availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}c"]
  subnet_ids                = ["${module.vpc.private_subnets}"]
  key_name                  = "${aws_key_pair.deployer.key_name}"
  security_group_ids        = ["${aws_security_group.ssh.id}", "${aws_security_group.consul.id}", "${aws_security_group.nomad.id}"]
  iam_instance_profile_name = "${aws_iam_instance_profile.servers.name}"
  ignition_user_ids         = ["${data.ignition_user.ameissner.id}"]
  ignition_group_ids        = ["${data.ignition_group.ameissner.id}"]
  ignition_systemd_ids      = ["${data.ignition_systemd_unit.docker_tcp_socket.id}"]
}
