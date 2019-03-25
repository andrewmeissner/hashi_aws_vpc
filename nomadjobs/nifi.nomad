job "nifi" {
  datacenters = ["us-west-2"]
  type        = "service"

  update {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "45s"
    healthy_deadline = "5m"
    auto_revert      = true
    stagger          = "1s"
  }

  group "nifi" {
    count = 1

    constraint {
      distinct_hosts = true
    }

    restart {
      attempts = 3
      delay    = "5s"
      interval = "1m"
      mode     = "delay"
    }

    task "nifi" {
      constraint {
        attribute = "${meta.role}"
        value     = "infra"
      }

      driver = "docker"

      config {
        image        = "apache/nifi:latest"
        network_mode = "host"
        tty          = true

        port_map {
          http = 8080
        }
      }

      resources {
        cpu    = 2000
        memory = 4000

        network {
          mbits = 50

          port "http" {
            static = 8080
          }
        }
      }

      service {
        check {
          name     = "nifi"
          type     = "http"
          port     = "http"
          path     = "/nifi"
          interval = "10s"
          timeout  = "2s"
        }

        name = "nifi"
        port = "http"
      }
    }
  }
}
