/**
* Deployment
**/

variable "deployment_name" {
    description = "Name of deployment"
    type        = string
    default     = "ingress-nginx-controller"
}

variable "deployment_min_ready_seconds" {
    description = "Min ready seconds"
    type        = number
    default     = 0
}

variable "deployment_revision_history_limit" {
    description = "Revision History limit"
    type        = number
    default     = 10
}

variable "deployment_extra_container_args" {
    description = "Extra args for container."
    type        = list(string)
    default     = [ ]
}

variable "deployment_image" {
    description = "Deployment image."
    type        = string
    default     = "k8s.gcr.io/ingress-nginx/controller:v1.2.0@sha256:d8196e3bc1e72547c5dec66d6556c0ff92a23f6d0919b206be170bc90d5f9185"
}

/**
* Service
**/

variable "service_name" {
    description = "Name of the ingress service"
    type        = string
    default     = "ingress-nginx-controller"
}
variable "admission_service_name" {
    description = "Name of the ingress admission service"
    type        = string
    default     = "ingress-nginx-controller-admission"
}

variable "service_annotations" {
    description = "Annotations for the service. By default, this is configured for AWS"
    type        = object({})
    default     = {
        "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                  = "tcp"
        "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
        "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
    }
}

/**
* Configmap
**/

variable "config_map_name" {
    description = "Name of configmap"
    type        = string
    default     = "ingress-nginx-controller"
}

/**
* Namespace
**/

variable "create_namespace" {
    description = "Decides if the module should create a namespace, 1 = true, 0 = false."
    type        = number
    default     = 0
}

variable "namespace" {
    description = "Namespace name"
    type        = string
}

/**
* RBAC
**/

variable "service_account_name" {
    description = "Name of service account"
    type        = string
    default     = "ingress-nginx"
}

variable "role_name" {
    description = "Name of the kubernetes role"
    type        = string
    default     = "ingress-nginx"
}

variable "cluster_role_name" {
    description = "Name of the cluster role"
    type        = string
    default     = "ingress-nginx"
}