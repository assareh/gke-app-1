variable "gcp_credentials" {
  description = "GCP credentials needed by google provider"
}

variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default     = "us-west1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default     = "us-west1-b"
}

variable "gcp_project" {
  description = "GCP project name"
}

data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "multicloud-provisioning-demo"
    workspaces = {
      name = "02-gke-cluster"
    }
  }
}

provider "google" {
  credentials = var.gcp_credentials
  project     = var.gcp_project
  region      = var.gcp_region
}

provider "kubernetes" {
  #version                = "1.10.0"
  load_config_file       = "false"
  host                   = "https://${data.terraform_remote_state.cluster.outputs.cluster_endpoint}"
  token                  = data.terraform_remote_state.cluster.outputs.cluster_access_token
#  client_certificate     = base64decode(google_container_cluster.default.master_auth.0.client_certificate)
#  client_key             = base64decode(google_container_cluster.default.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_cluster_ca_certificate)
}

#provider "kubernetes" {
#  version                = "1.9"
##  load_config_file       = "false"
 # host                   = "https://35.185.254.112"
 # token                  = "ya29.c.KpYBwAehLErWGPaZa8GUWIvbtZSkI3XgA5NP9f_2MKDWzNv8J6edTK8NBNcGkMR9Ge4wDeGol3aYExJDsw-8cNj3nJhDqEK4vJNutrneWKbjuZUmI6Jcd8fZS7Uv01ZqRqIfu2R-HrdQ8KDR1YIO-x91TJod29B3wPdjsjC-hPZfpwhdlVodsc3cXZ4VhxWJ5jJK2ateys3T"
#  client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_client_certificate)
#  client_key             = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_client_key)
  #cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURDekNDQWZPZ0F3SUJBZ0lRWTZNam1ZMy9RY200S3VpUmVIb2EvekFOQmdrcWhraUc5dzBCQVFzRkFEQXYKTVMwd0t3WURWUVFERXlSaU9EWTNaRFF4TlMwMVltVTBMVFF5TlRRdFlUSmlPUzB4WVdVMU1qUmhaak5sWVRJdwpIaGNOTWpBd016QXpNVGMxT0RBNVdoY05NalV3TXpBeU1UZzFPREE1V2pBdk1TMHdLd1lEVlFRREV5UmlPRFkzClpEUXhOUzAxWW1VMExUUXlOVFF0WVRKaU9TMHhZV1UxTWpSaFpqTmxZVEl3Z2dFaU1BMEdDU3FHU0liM0RRRUIKQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUR5Sy9BaEFSbnVKWjVmVmlsVXNTQWJuOXJhakF6aGpFMzdCaGlicXh3cgo3RTFFOWg0WFdSMW00K3R2bkNqMHBJQTVEN0YwUHUyWktWdVoxelJScmdObU90cFNXMmJJWmNldHE1dk5UbTF2CmQzOCs0RGI2KytPR2RQR0w3YWd6RU5relVycENPaitTekVYeHNrVWFEUkNFZlFWd1JYSE9XdEZwMmFjTnViSzgKbnYrTFRyVmVTNXVzVnJ5QmEraWV5ZmNzbktBMlp1U0tYN2Ezc0JoOXJ5bFhGQVFiWTFLWmxwdnZHeHg2TWlUMwppby8wN3BJaUYwdHI0VmlEVWxXZXVhMWJSTXpBQWIxK1laVHQ0aUc5d2NaQWx1U3l5ODRJOGxCRWR4aE1sQjQrCmtOMUlhdy9iZHNSNjdrOUNjMXAzUUZSS1dpdFpZWmV6T250UWRsV0RqazJaQWdNQkFBR2pJekFoTUE0R0ExVWQKRHdFQi93UUVBd0lDQkRBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCQVFCdQp0WWtNUDdxSVRJdWVsT28zMzAxWGJZTG9PVWFRSjRmRVdFUXg4dUhoeVhLbEF4UE1uYlVlangzR2JMMVIzZ1BICk9ZTDk3aGFnazY4RXFMMExsM1NHVXRVeHh4WEVsSUdqdlFQbjNWcTlDaG4vMEx6a2FONjBJbHdGemw3MkdlZEIKZmpXMC9sZ1lFMGxpZ1JPd3lqZFJZOG8zakdzVFRSRTgrMnJESmhYTms1Y1ZUMDBaeTBib2xvTXV5bXdjQXZMdAoxVlJQU2NIWXIrdDYzeUlVTG9SNlpQekljN1ZVSmdqU3hNNXBNSFFsSmR0SGR3bkVGQXZtdm51dThVb2ZvbzVDCkNyVHd3bHQyU2pNeFFQTm5kU0IzczYvSnBjUXZ3SHpDcVVJd29DWTV3U0ZxY0xxVGtxdXBuOXBRT0JReUVtdmkKUzRIeUpqWWdYd1pjZ3EvYkkrbVMKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=")
#}

resource "google_compute_address" "default" {
  name   = var.gcp_project
  region = var.gcp_region
}

resource "kubernetes_service" "nginx" {
  metadata {
    namespace = data.terraform_remote_state.cluster.outputs.cluster_namespace
    name      = "nginx"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.default.address
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    namespace = data.terraform_remote_state.cluster.outputs.cluster_namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.7.9"
          name  = "nginx"
        }
      }
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 10"
  }
}

output "load-balancer-ip" {
  value = "${google_compute_address.default.address}"
}
