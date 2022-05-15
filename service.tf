resource "kubernetes_service" "nginx-controller-service" {
    metadata {
        name      = var.service_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }

        annotations = var.service_annotations
    }

    spec {
        external_traffic_policy = "local"

        port {
            name        = "http"
            port        = 80
            target_port = "http"
            protocol    = "TCP"
        }

        port {
            name        = "https"
            port        = 443
            target_port = "https"
            protocol    = "TCP"
        }

        selector = {
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/instance"  = "ingress-nginx"
            "app.kubernetes.io/name"      = "ingress-nginx"
        }

        type = "LoadBalancer"
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_service" "nginx-controller-admission-service" {
    metadata {
        name      = var.admission_service_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    spec {
        port {
            name        = "https-webhook"
            port        = 443
            target_port = "webhook"
        }

        selector = {
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/instance"  = "ingress-nginx"
            "app.kubernetes.io/name"      = "ingress-nginx"
        }

        type = "ClusterIP"
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}