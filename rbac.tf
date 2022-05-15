resource "kubernetes_service_account" "nginx-service-account" {
    metadata {
        name      = var.service_account_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_service_account" "nginx-service-admission-account" {
    metadata {
        name      = "${var.service_account_name}-admission"
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_role" "nginx-role" {
    metadata {
        name      = var.role_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "namespaces" ]
        verbs      = [ "get" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "configmaps", "pods", "secrets", "endpoints" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "services" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingresses" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingresses/status" ]
        verbs      = [ "update" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingressclasses" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups     = [ "" ]
        resource_names = [ "ingress-controller-leader" ]
        resources      = [ "configmaps" ]
        verbs          = [ "get", "update" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "configmaps" ]
        verbs      = [ "create" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "events" ]
        verbs      = [ "create", "patch" ]
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_role" "nginx-admission-role" {
    metadata {
        name      = "${var.role_name}-admission"
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "secrets" ]
        verbs      = [ "get", "create" ]
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace
    ]
}

resource "kubernetes_cluster_role" "nginx-cluster-role" {
    metadata {
        name = var.cluster_role_name

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "configmaps", "endpoints", "nodes", "pods", "secrets", "namespaces" ]
        verbs      = [ "list", "watch" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "nodes" ]
        verbs      = [ "get" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "services" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingresses" ]
        verbs      = [ "get", "list", "watch" ]
    }

    rule {
        api_groups = [ "" ]
        resources  = [ "events" ]
        verbs      = [ "create", "patch" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingresses/status" ]
        verbs      = [ "update" ]
    }

    rule {
        api_groups = [ "networking.k8s.io" ]
        resources  = [ "ingressclasses" ]
        verbs      = [ "get", "list", "watch" ]
    }
}

resource "kubernetes_cluster_role" "nginx-admission-cluster-role" {
    metadata {
        name = "${var.cluster_role_name}-admission"

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }

    rule {
        api_groups = [ "admissionregistration.k8s.io" ]
        resources  = [ "validatingwebhookconfigurations" ]
        verbs      = [ "get", "update" ]
    }
}

resource "kubernetes_role_binding" "nginx-role-binding" {
    metadata {
        name      = var.role_name
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = var.role_name
    }
    subject {
        kind      = "ServiceAccount"
        name      = var.service_account_name
        namespace = var.namespace
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace,
        kubernetes_role.nginx-role
    ]
}

resource "kubernetes_role_binding" "nginx-admission-role-binding" {
    metadata {
        name      = "${var.role_name}-admission"
        namespace = var.namespace

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = "${var.role_name}-admission"
    }
    subject {
        kind      = "ServiceAccount"
        name      = "${var.service_account_name}-admission"
        namespace = var.namespace
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace,
        kubernetes_role.nginx-admission-role
    ]
}

resource "kubernetes_cluster_role_binding" "nginx-cluster-role-binding" {
    metadata {
        name = var.role_name

        labels = {
            "app.kubernetes.io/component" = "controller"
        }
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = var.cluster_role_name
    }
    subject {
        kind      = "ServiceAccount"
        name      = var.service_account_name
        namespace = var.namespace
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace,
        kubernetes_cluster_role.nginx-cluster-role
    ]
}

resource "kubernetes_cluster_role_binding" "nginx-admission-cluster-role-binding" {
    metadata {
        name = "${var.role_name}-admission"

        labels = {
            "app.kubernetes.io/component" = "admission-webhook"
        }
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "${var.cluster_role_name}-admission"
    }
    subject {
        kind      = "ServiceAccount"
        name      = "${var.service_account_name}-admission"
        namespace = var.namespace
    }

    depends_on = [
        kubernetes_namespace.nginx-namespace,
        kubernetes_cluster_role.nginx-admission-cluster-role
    ]
}