variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID"
  type        = string
}

variable "eligible_principals" {
  description = "The eliable that can access the entitlement"
  type        = list(string)
}

variable "approver_principals" {
  description = "The list that can approve the entitlement"
  type        = list(string)
}
