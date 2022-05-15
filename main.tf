resource "kubernetes_namespace" "nginx-namespace" {
    count = var.create_namespace

    metadata {
        name = var.namespace
    }
}

resource "kubernetes_config_map" "nginx-configmap" {
    metadata {
        name      = var.config_map_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_ingress_class" "nginx-ingress-class" {

    metadata {
        name = "nginx"

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    spec {
        controller = "k8s.io/ingress-nginx"
    }

}

resource "kubernetes_manifest" "nginx-admission-validation" {
    manifest = {
        apiVersion = "admissionregistration.k8s.io/v1"
        kind       = "ValidatingWebhookConfiguration"

        metadata   = {
            name = "ingress-nginx-admission"

            labels = {
                "app.kubernetes.io/component" = "admission-webhook"
                "app.kubernetes.io/instance"  = "ingress-nginx"
                "app.kubernetes.io/name"      = "ingress-nginx"
                "app.kubernetes.io/part-of"   = "ingress-nginx"
                "app.kubernetes.io/version"   = "1.2.0"
            }
        }

        webhooks = [
            {
                admissionReviewVersions = [
                    "v1",
                ]

                clientConfig = {
                    service = {
                        name      = "ingress-nginx-controller-admission"
                        namespace = "ingress-nginx"
                        path      = "/networking/v1/ingresses"
                    }
                }

                failurePolicy = "Fail"
                matchPolicy   = "Equivalent"
                name          = "validate.nginx.ingress.kubernetes.io"

                rules         = [
                    {
                        apiGroups = [
                            "networking.k8s.io",
                        ]

                        apiVersions = [
                            "v1",
                        ]

                        operations = [
                            "CREATE",
                            "UPDATE",
                        ]

                        resources = [
                            "ingresses",
                        ]
                    },
                ]

                sideEffects = "None"
            }
        ]
    }
}
