resource "kubernetes_job" "nginx-admission-create" {
    metadata {
        name      = "${var.admission_service_name}-create"
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }

    spec {
        template {
            metadata {
                name = "${var.admission_service_name}-create"

                labels = {
                    "app.kubernetes.io/component" = "admission-webhook"
                }
            }

            spec {
                service_account_name = "${var.service_account_name}-admission"

                node_selector = {
                    "kubernetes.io/os" = "linux"
                }

                restart_policy = "OnFailure"

                security_context {
                    fs_group        = "2000"
                    run_as_non_root = "true"
                    run_as_user     = "2000"
                }

                container {
                    name = "create"

                    image             = "k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1@sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660"
                    image_pull_policy = "IfNotPresent"

                    args = [
                        "create",
                        "--host=${var.deployment_name}-admission,${var.deployment_name}-admission.$(POD_NAMESPACE).svc",
                        "--namespace=$(POD_NAMESPACE)",
                        "--secret-name=ingress-nginx-admission"
                    ]

                    env {
                        name = "POD_NAMESPACE"
                        value_from {
                            field_ref {
                                field_path = "metadata.namespace"
                            }
                        }
                    }

                    security_context {
                        allow_privilege_escalation = "false"
                    }
                }
            }
        }
    }
}

resource "kubernetes_job" "nginx-admission-patch" {
    metadata {
        name      = "${var.admission_service_name}-patch"
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }

    spec {
        template {
            metadata {
                name = "${var.admission_service_name}-path"

                labels = {
                    "app.kubernetes.io/component" = "admission-webhook"
                }
            }

            spec {
                service_account_name = "${var.service_account_name}-admission"

                node_selector = {
                    "kubernetes.io/os" = "linux"
                }

                restart_policy = "OnFailure"

                security_context {
                    fs_group        = "2000"
                    run_as_non_root = "true"
                    run_as_user     = "2000"
                }

                container {
                    name = "patch"

                    image             = "k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1@sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660"
                    image_pull_policy = "IfNotPresent"

                    args = [
                        "patch",
                        "--webhook-name=${var.service_account_name}-admission",
                        "--namespace=$(POD_NAMESPACE)",
                        "--patch-mutating=false",
                        "--secret-name=ingress-nginx-admission",
                        "--patch-failure-policy=Fail"
                    ]

                    env {
                        name = "POD_NAMESPACE"
                        value_from {
                            field_ref {
                                field_path = "metadata.namespace"
                            }
                        }
                    }

                    security_context {
                        allow_privilege_escalation = "false"
                    }
                }
            }
        }
    }
}