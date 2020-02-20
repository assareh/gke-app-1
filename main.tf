provider "kubernetes" {
  load_config_file = "false"

  host = "https://${data.terraform_remote_state.cluster.outputs.k8s_endpoint}"

  client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.k8s_master_auth_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.cluster.outputs.k8s_master_auth_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.k8s_master_auth_cluster_ca_certificate)
}

data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "multicloud-provisioning-demo"
    workspaces = {
      name = "gke-cluster-dev"
    }
  }
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}

resource "kubernetes_pod" "test" {
  metadata {
    name = "terraform-example"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"

      env {
        name  = "environment"
        value = "test"
      }

      liveness_probe {
        http_get {
          path = "/nginx_status"
          port = 80

          http_header {
            name  = "X-Custom-Header"
            value = "Awesome"
          }
        }

        initial_delay_seconds = 3
        period_seconds        = 3
      }
    }

    dns_config {
      nameservers = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
      searches    = ["example.com"]

      option {
        name  = "ndots"
        value = 1
      }

      option {
        name = "use-vc"
      }
    }

    dns_policy = "None"
  }
}