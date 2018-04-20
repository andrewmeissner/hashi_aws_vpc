job "new_vault" {
  datacenters = ["us-west-2"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "10m"
    auto_revert = true
  }

  constraint {
    attribute = "${meta.role}"
    value = "infra"
  }

  group "new_vault" {
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

    task "new_vault" {
      driver = "docker"
      config {
        image = "vault:0.10.0"
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

    //   service {
    //     name = "vault"
    //     port = "http"
    //     check {
    //       name = "vault"
    //       type = "tcp"
    //       interval = "10s"
    //       timeout = "2s"
    //     }
    //   }

    //   template {
    //     destination = "local/vault_conf.hcl"
    //     data = <<EOF
    //     backend "consul" {
    //         address = "{{ env "attr.unique.network.ip-address" }}:8500"
    //         path    = "vault"
    //         scheme  = "http"
    //         service = "vault"
    //     }

    //     listener "tcp" {
    //         address     = "0.0.0.0:8200"
    //         tls_disable = 1
    //     }
    //     ui = true
    //     disable_mlock = true
    //     EOF
    //   }
    }
  }
}
