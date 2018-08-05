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

data "ignition_file" "etc_resolv" {
  path       = "/etc/systemd/resolved.conf.d/00-consul-dns.conf"
  filesystem = "root"
  mode       = 644

  content {
    content = <<EOF
[Resolve]
DNS=127.0.0.1
EOF
  }
}

data "ignition_file" "docker_daemon" {
  filesystem = "root"
  path       = "/etc/docker/daemon.json"
  mode       = 644

  content {
    mime = "application/json"

    content = <<EOF
{
    "insecure-registries": ["registry.${var.domain}"]
}
EOF
  }
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
