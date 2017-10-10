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
  --retry 10)\nCUSTOM_EC2_INSTANCE_ID=$(curl -s\
  --url http://169.254.169.254/2009-04-04/meta-data/instance-id\
  --retry 10)\nX_CLIENT_TYPE=$${client_type}" > /run/metadata/ec2'
EOF
}

data "ignition_systemd_unit" "consul_client" {
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
ExecStartPre=/opt/bin/consul-template -template "/opt/conf/consul-client.json.ctmpl:/opt/conf/consul-client.json" -once
ExecStart=/opt/bin/consul agent -config-file=/opt/conf/consul-client.json
Restart=always

[Install]
RequiredBy=nomad.service
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "nomad_client" {
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
ExecStartPre=/opt/bin/consul-template -template "/opt/conf/nomad-client.hcl.ctmpl:/opt/conf/nomad-client.hcl" -once
ExecStart=/opt/bin/nomad agent -config=/opt/conf/nomad-client.hcl
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_file" "consul_client_config" {
  filesystem = "root"
  path       = "/opt/conf/consul-client.json.ctmpl"
  mode       = 644

  content {
    mime = "application/json"

    content = <<EOF
{
    "advertise_addr": "{{ env "CUSTOM_EC2_IPV4_LOCAL" }}",
    "bind_addr": "0.0.0.0",
    "client_addr": "0.0.0.0",
    "data_dir": "/opt/data/consul.d",
    "datacenter": "${var.region}",
    "retry_join": ["provider=aws tag_key=Consul-Server tag_value=true region=${var.region}"],
    "node_meta": {
        "agent": "client",
        "type": "{{ env "X_CLIENT_TYPE" }}"
    },
    "ports": {
        "dns": 53
    },
    "node_name": "{{ env "X_CLIENT_TYPE" }}-{{ env "CUSTOM_EC2_INSTANCE_ID" }}",
    "ui": true
}
EOF
  }
}

data "ignition_file" "nomad_client_config" {
  filesystem = "root"
  path       = "/opt/conf/nomad-client.hcl.ctmpl"
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
name = "{{ env "X_CLIENT_TYPE" }}-{{ env "CUSTOM_EC2_INSTANCE_ID" }}"
client {
    enabled = true
    meta {
        "role" = "{{ env "X_CLIENT_TYPE" }}"
        "name" = "{{ env "X_CLIENT_TYPE" }}-{{ env "CUSTOM_EC2_INSTANCE_ID" }}"
    }
    options {
        "driver.raw_exec.enable" = "1"
        "docker.cleanup.image" = "true"
        "docker.cleanup.image.delay" = "30m"
        "docker.volumes.enabled" = "true"
        "docker.privileged.enabled" = "true"
    }
}
EOF
  }
}

data "ignition_config" "client_config" {
  users  = ["${var.ignition_user_ids}"]
  groups = ["${var.ignition_group_ids}"]

  files = [
    "${var.ignition_file_ids}",
    "${data.ignition_file.consul_client_config.id}",
    "${data.ignition_file.nomad_client_config.id}",
  ]

  systemd = [
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.consul_client.id}",
    "${data.ignition_systemd_unit.nomad_client.id}",
    "${var.ignition_systemd_ids}",
  ]
}
