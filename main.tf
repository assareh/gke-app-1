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
  client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_master_auth_cluster_ca_certificate)
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "google_compute_address" "default" {
  name   = var.gcp_project
  region = var.gcp_region
}

resource "kubernetes_service" "nginx" {
  metadata {
    namespace = kubernetes_namespace.staging.metadata.0.name
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
    namespace = kubernetes_namespace.staging.metadata.0.name
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
}

output "load-balancer-ip" {
  value = "${google_compute_address.default.address}"
}
