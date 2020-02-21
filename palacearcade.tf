resource "kubernetes_service" "palacearcade" {
  metadata {
    namespace = data.terraform_remote_state.cluster.outputs.cluster_namespace
    name      = "palacearcade"
  }

  spec {
    selector = {
      app = "palacearcade"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.palacearcade.address
  }
}

resource "kubernetes_deployment" "palacearcade" {
  metadata {
    name = "palacearcade"
    namespace = data.terraform_remote_state.cluster.outputs.cluster_namespace
    labels = {
      app = "palacearcade"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "palacearcade"
      }
    }

    template {
      metadata {
        labels = {
          app = "palacearcade"
        }
      }

      spec {
        container {
          image = "scarolan/palacearcade"
          name  = "palacearcade"
        }
      }
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 10"
  }
}

resource "google_compute_address" "palacearcade" {
  name   = "${var.gcp_project}-palacearcade"
  region = var.gcp_region
}

output "palace-load-balancer-ip" {
  value = "${google_compute_address.palacearcade.address}"
}
