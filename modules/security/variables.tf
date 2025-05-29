### variables.tf ###

variable "folder_id" {
  description = "Yandex Cloud Folder ID where security resources will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag (dev, stage, prod, …) used in resource names"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project slug used as a prefix for all security-related resource names"
  type        = string
  default     = "chistologic"
}

variable "vpc_id" {
  description = "ID of the VPC network. If null, security‑groups are not created."
  type        = string
  default     = null
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (used in the LB/Ingress SG). Optional."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (used in the K8s nodes SG). Optional."
  type        = list(string)
  default     = []
}

variable "db_subnet_ids" {
  description = "List of DB subnet IDs. Optional."
  type        = list(string)
  default     = []
}

variable "enable_waf" {
  description = "Whether to enable Web Application Firewall for the ALB listener"
  type        = bool
  default     = true
}

variable "waf_policy_ruleset" {
  description = "Preset ruleset for WAF (e.g. OWASP_CRS, PCI_DSS). Ignored if enable_waf=false."
  type        = string
  default     = "OWASP_CRS"
  validation {
    condition     = contains(["OWASP_CRS", "PCI_DSS", "HIPAA"], var.waf_policy_ruleset)
    error_message = "Allowed WAF presets: OWASP_CRS, PCI_DSS, HIPAA."
  }
}
