data "ignition_systemd_unit" "metadata" {
  name = "metadata.service"

  content = <<EOF
[Unit]
Description=EC2 metadata agent

[Service]
User=root
Type=oneshot
ExecStart=/usr/bin/mkdir --parent /run/metadata
ExecStart=/usr/bin/bash -c 'echo -e "CUSTOM_EC2_IPV4_LOCAL=$(curl -s\
  --url http://169.254.169.254/2009-04-04/meta-data/local-ipv4\
  --retry 10)\nX_CONSUL_NAME=$${consul_name}\nX_NOMAD_NAME=$${nomad_name}" > /run/metadata/ec2'
EOF
}

data "ignition_systemd_unit" "consul_server" {
  name = "consul.service"

  content = <<EOF
[Unit]
Description=Consul Server
Requires=metadata.service
After=metadata.service

[Service]
User=root
Type=simple
EnvironmentFile=/run/metadata/ec2
ExecStartPre=/opt/bin/consul-template -template "/opt/conf/consul-server.json.ctmpl:/opt/conf/consul-server.json" -once
ExecStart=/opt/bin/consul agent -config-file=/opt/conf/consul-server.json
Restart=always

[Install]
RequiredBy=nomad.service
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "nomad_server" {
  name = "nomad.service"

  content = <<EOF
[Unit]
Description=Nomad Server
After=metadata.service
Requires=consul.service

[Service]
User=root
Type=simple
EnvironmentFile=/run/metadata/ec2
ExecStartPre=/opt/bin/consul-template -template "/opt/conf/nomad-server.hcl.ctmpl:/opt/conf/nomad-server.hcl" -once
ExecStart=/opt/bin/nomad agent -config=/opt/conf/nomad-server.hcl
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_file" "consul_server_config" {
  filesystem = "root"
  path       = "/opt/conf/consul-server.json.ctmpl"
  mode       = 644

  content {
    mime = "application/json"

    content = <<EOF
{
    "advertise_addr": "{{ env "CUSTOM_EC2_IPV4_LOCAL" }}",
    "bind_addr": "0.0.0.0",
    "bootstrap_expect": 3,
    "client_addr": "0.0.0.0",
    "data_dir": "/opt/data/consul.d",
    "datacenter": "${var.region}",
    "retry_join": ["provider=aws tag_key=Consul-Server tag_value=true region=${var.region}"],
    "node_meta": {
        "agent": "server",
        "type": "core"
    },
    "ports": {
        "dns": 53
    },
    "node_name": "{{ env "X_CONSUL_NAME" }}",
    "server": true,
    "ui": true
}
EOF
  }
}

data "ignition_file" "nomad_server_config" {
  filesystem = "root"
  path       = "/opt/conf/nomad-server.hcl.ctmpl"
  mode       = 0644

  content {
    content = <<EOF
advertise {
    http = "{{ env "CUSTOM_EC2_IPV4_LOCAL" }}"
    rpc = "{{ env "CUSTOM_EC2_IPV4_LOCAL" }}"
    serf = "{{ env "CUSTOM_EC2_IPV4_LOCAL" }}"
}
data_dir = "/opt/data/nomad.d"
datacenter = "${var.region}"
name = "{{ env "X_NOMAD_NAME" }}"
server {
    enabled = true
    bootstrap_expect = 3
}
EOF
  }
}

data "ignition_config" "servers_config" {
  users  = ["${var.ignition_user_ids}"]
  groups = ["${var.ignition_group_ids}"]

  files = [
    "${data.ignition_file.consul_server_config.id}",
    "${data.ignition_file.nomad_server_config.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.consul_server.id}",
    "${data.ignition_systemd_unit.nomad_server.id}",
    "${var.ignition_systemd_ids}",
  ]
}
