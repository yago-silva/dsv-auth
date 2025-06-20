variable "admin_user" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

job "keycloak" {
  datacenters = ["dc1"]
  type = "service"
  group "postgres" {
    count = 1

    network {
      port "keycloak_port" {
        to = 8080
        static = 8080 
      }
    }

    service {
      port = "keycloak_port"
      provider = "nomad"
    }

    task "keycloak" {
      driver = "docker"

      config {
        image = "quay.io/keycloak/keycloak:23.0.6"
        ports = ["keycloak_port"]
        args  = ["start"]
      }

      env {
        KC_HOSTNAME = "localhost"
        KC_HOSTNAME_PORT = 8080
        KC_HOSTNAME_STRICT_BACKCHANNEL= "false"
        KC_HTTP_ENABLED = "true"
        KC_HOSTNAME_STRICT_HTTPS = "false"
        KC_HEALTH_ENABLED = "true"
        KEYCLOAK_ADMIN = var.admin_user
        KEYCLOAK_ADMIN_PASSWORD = var.admin_password
        KC_DB = "postgres"
        KC_DB_URL = "jdbc:postgresql://postgres:5432/keycloak"
        KC_DB_USERNAME = var.db_user
        KC_DB_PASSWORD = var.db_password
      }

      resources {
        cpu    = var.cpu # MHz
        memory = var.memory # MB
      }
    }
  }
}