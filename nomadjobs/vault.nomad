job "vault" {
  datacenters = ["us-west-2"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    auto_revert = false
  }

  constraint {
    attribute = "${meta.role}"
    value = "infra"
  }

  group "vault" {
    constraint {
      distinct_hosts = true
    }
    count = 3
    restart {
      attempts = 10
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }

    task "vault" {
      driver = "docker"
      config {
        image = "vault:1.0.2"
        command = "server"
        network_mode = "host"
        cap_add = [
            "IPC_LOCK",
        ]
        port_map {
          http = 8200
          cluster = 8201
        }
      }

      env {
          VAULT_LOCAL_CONFIG = "{\"storage\":{\"consul\":{\"address\":\"${NOMAD_IP_http}:8500\",\"scheme\":\"http\",\"service\":\"vault\",\"path\":\"vault\"}},\"listener\":{\"tcp\":{\"address\":\"0.0.0.0:8200\",\"tls_disable\":true}},\"disable_mlock\":true,\"ui\":true}"
      }

      resources {
        cpu = 500
        memory = 256
        network {
          mbits = 10
          port "http" {
            static = 8200
          }
          port "cluster" {
              static = 8201
          }
        }
      }
    }
  }
}
