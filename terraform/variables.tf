variable "aws_region" {
  default = "ap-south-1"
}

variable "app_name" {
  default = "hello-world-app"
}

variable "ecs_cluster_name" {
  default = "hello-world-cluster"
}

variable "task_memory" {
  default = "512"
}

variable "task_cpu" {
  default = "256"
}

variable "desired_count" {
  default = "1"
}

variable "docker_image" {
  description = "637423471839.dkr.ecr.ap-south-1.amazonaws.com/hello-world-nodejs:latest"
}