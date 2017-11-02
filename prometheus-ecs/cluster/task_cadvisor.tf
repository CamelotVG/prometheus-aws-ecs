resource "aws_ecs_task_definition" "cadvisor" {
  family                = "cadvisor"
  network_mode          = "bridge"
  container_definitions = "${file("${path.module}/files/task_cadvisor.json")}"

  volume {
    name      = "root"
    host_path = "/"
  }

  volume {
    name      = "var_run"
    host_path = "/var/run"
  }

  volume {
    name      = "var_lib_docker"
    host_path = "/var/lib/docker/"
  }

  volume {
    name      = "cgroup"
    host_path = "/cgroup"
  }

  volume {
    name      = "sys"
    host_path = "/sys"
  }
}
