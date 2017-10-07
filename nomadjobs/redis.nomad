
job "redis" {
  datacenters = ["us-west-2"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = true
    canary = 0
  }
  group "cache" {
    count = 3
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      sticky = true
      # 
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      migrate = true

      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 300
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:3.2"
        port_map {
          db = 6379
        }
      }

      resources {
        cpu    = 500 
        memory = 256 
        network {
          mbits = 10
          port "db" {}
        }
      }

      service {
        name = "redis"
        tags = ["redis", "cache"]
        port = "db"
        check {
          name     = "redis"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
