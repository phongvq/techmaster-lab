variable "project_id" {
  description = "The ID of the project in which to create the VPC."
  type        = string
}

variable "region" {
  description = "The region to create resources in."
  type        = string
}

variable "prefix" {
  description = "prefix for creating resources."
  type        = string
  default     = ""
}

variable "ip_cidr_range" {
  description = "CIDR for subnet."
  type        = string
  default     = ""
}
