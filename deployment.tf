resource "kubernetes_deployment" "nginx-ingress-deployment" {
    metadata {
        name      = var.deployment_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }
    spec {
        min_ready_seconds    = var.deployment_min_ready_seconds
        revisionHistoryLimit = var.deployment_revision_history_limit

        selector {
            match_labels = {
                "app.kubernetes.io/component" = "controller"
                "app.kubernetes.io/instance"  = "ingress-nginx"
                "app.kubernetes.io/name"      = "ingress-nginx"
            }
        }

        template {
            metadata {
                labels = {
                    "app.kubernetes.io/component" = "controller"
                    "app.kubernetes.io/instance"  = "ingress-nginx"
                    "app.kubernetes.io/name"      = "ingress-nginx"
                }
            }

            spec {
                dns_policy = "ClusterFirst"

                node_selector = {
                    "kubernetes.io/os" = "linux"
                }

                service_account_name             = var.service_account_name
                termination_grace_period_seconds = 30

                volume {
                    name = "webhook-cert"
                    secret {
                        secret_name = "ingress-nginx-admission"
                    }
                }

                container {
                    name = "controller"

                    image             = var.deployment_image
                    image_pull_policy = "IfNotPresent"

                    args = merge(var.deployment_extra_container_args, [
                        "/nginx-ingress-controller",
                        "--publish-service=$(POD_NAMESPACE)/${var.service_name}",
                        "--election-id=ingress-controller-leader",
                        "--controller-class=k8s.io/ingress-nginx",
                        "--ingress-class=nginx",
                        "--configmap=$(POD_NAMESPACE)/${var.config_map_name}",
                        "--validating-webhook=:8443",
                        "--validating-webhook-certificate=/usr/local/certificates/cert",
                        "--validating-webhook-key=/usr/local/certificates/key"
                    ])

                    resources {
                        requests = {
                            cpu : "100m"
                            memory : "90Mi"
                        }
                    }

                    security_context {
                        allow_privilege_escalation = "true"
                        capabilities {
                            add = [
                                "NET_BIND_SERVICE"
                            ]
                            drop = [
                                "ALL"
                            ]
                        }
                        run_as_user = "101"
                    }

                    volume_mount {
                        mount_path = "/usr/local/certificates/"
                        name       = "webhook-cert"
                        read_only  = "true"
                    }

                    port {
                        name           = "http"
                        protocol       = "TCP"
                        container_port = 80
                    }

                    port {
                        name           = "https"
                        protocol       = "TCP"
                        container_port = 443
                    }

                    port {
                        name           = "webhook"
                        protocol       = "TCP"
                        container_port = 8443
                    }

                    readiness_probe {
                        failure_threshold = 3
                        http_get {
                            path   = "/healthz"
                            port   = 10254
                            scheme = "HTTP"
                        }
                        initial_delay_seconds = 10
                        period_seconds        = 10
                        success_threshold     = 1
                        timeout_seconds       = 1
                    }

                    liveness_probe {
                        failure_threshold = 5
                        http_get {
                            path   = "/healthz"
                            port   = 10254
                            scheme = "HTTP"
                        }
                        initial_delay_seconds = 10
                        period_seconds        = 10
                        success_threshold     = 1
                        timeout_seconds       = 1
                    }

                    lifecycle {
                        pre_stop {
                            exec {
                                command = [
                                    "/wait-shutdown"
                                ]
                            }
                        }
                    }

                    env {
                        name = "POD_NAME"
                        value_from {
                            field_ref {
                                field_path = "metadata.name"
                            }
                        }
                    }

                    env {
                        name = "POD_NAMESPACE"
                        value_from {
                            field_ref {
                                field_path = "metadata.namespace"
                            }
                        }
                    }

                    env {
                        name  = "LD_PRELOAD"
                        value = "/usr/local/lib/libmimalloc.so"
                    }
                }
            }
        }
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}