job "registry" {
  datacenters = ["us-west-2"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    auto_revert = true
  }

  constraint {
    attribute = "${meta.role}"
    value = "app"
  }

  group "registry" {
    constraint {
      distinct_hosts = true
    }
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "10s"
      mode = "delay"
    }

    task "registry" {
      driver = "docker"
      config {
        image = "registry:2"
        network_mode = "host"
        
        port_map {
          http = 5000
        }
      }

      resources {
        cpu = 500
        memory = 256
        network {
          mbits = 10
          port "http" {
            static = 5000
          }
        }
      }

      service {
        name = "registry"
        port = "http"
        check {
          name = "registry"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
