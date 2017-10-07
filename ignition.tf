data "ignition_systemd_unit" "docker_tcp_socket" {
  name = "docker-tcp.socket"

  content = <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=2375
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target
EOF
}

data "ignition_user" "ameissner" {
  name                = "ameissner"
  password_hash       = "${file("password")}"
  ssh_authorized_keys = ["${file("/Users/ameissner/.ssh/id_rsa.pub")}"]
  home_dir            = "/home/ameissner"
  shell               = "/bin/bash"
  primary_group       = "${data.ignition_group.ameissner.name}"
  groups              = ["sudo"]
}

data "ignition_group" "ameissner" {
  name = "ameissner"
}
