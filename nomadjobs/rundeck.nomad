job "rundeck" {
  datacenters = ["us-west-2"]
  type = "service"

  update {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "45s"
    healthy_deadline = "5m"
    auto_revert = true
    stagger = "1s"
  }

  group "rundeck" {
    count = 1

    constraint {
      distinct_hosts = true
    }

    restart {
      attempts = 3
      delay = "5s"
      interval = "1m"
      mode = "delay"
    }

    task "rundeck" {
      constraint {
        attribute = "${meta.role}"
        value = "infra"
      }

      driver = "docker"
      config {
        image = "jordan/rundeck:3.0.1"
        network_mode = "host"
        tty = true
        port_map {
          http = 4440
        }
      }

      env {
        RUNDECK_PASSWORD = "rundeckpassword"
        RUNDECK_ADMIN_PASSWORD = "admin"
        EXTERNAL_SERVER_URL = "http://${NOMAD_ADDR_http}"
        CLUSTER_MODE = "true"
        DATABASE_URL = "jdbc:postgresql://rundeck-db.service.consul/rundeckdb"
        RUNDECK_STORAGE_PROVIDER = "db"
        RUNDECK_PROJECT_STORAGE_TYPE = "db"
        NO_LOCAL_MYSQL = "true"
      }

      resources {
        cpu = 2000
        memory = 4000
        network {
          mbits = 50
          port "http" {
            static = 4440
          }
        }
      }

      service {
        check {
          name = "rundeck"
          type = "http"
          port = "http"
          path = "/user/login"
          interval = "10s"
          timeout = "2s"
        }

        name = "rundeck"
        port = "http"
      }
    }
  }
}