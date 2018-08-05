job "vault" {
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

  group "vault" {
    constraint {
      distinct_hosts = true
    }
    count = 2
    restart {
      attempts = 10
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }

    task "vault" {
      driver = "docker"
      config {
        image = "registry.sofidevops.com/vault:master-29"
        network_mode = "host"
        port_map {
          http = 8200
          cluster = 8201
        }
      }

      env {
          NODE_IP = "${NOMAD_IP_http}"
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
    }
  }
}
