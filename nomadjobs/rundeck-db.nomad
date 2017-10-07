job "rundeck-db" {
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

    group "rundeck-db" {
    count = 1

    ephemeral_disk {
      migrate = true
      size = "300"
      sticky = true
    }

    constraint {
      distinct_hosts = true
    }

    restart {
      attempts = 1
      delay = "5s"
      interval = "1m"
      mode = "delay"
    }

    task "rundeck-db" {
      constraint {
        attribute = "${meta.role}"
        value = "data"
      }

      driver = "docker"
      config {
        image = "mysql"
        network_mode = "host"
        port_map {
          db = 3306
        }
        volumes = [
          "alloc:/var/lib/mysql"
        ]
      }

      env {
        MYSQL_ROOT_PASSWORD = "admin"
        MYSQL_DATABASE = "rundeckdb"
        MYSQL_USER = "root"
        MYSQL_PASSWORD = "admin"
      }

      resources {
        cpu = 1000
        memory = 1000
        network {
          mbits = 20
          port "db" {
            static = 3306
          }
        }
      }

      service {
        name = "rundeck-db"
        port = "db"
        check {
          name = "rundeck-db"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}

