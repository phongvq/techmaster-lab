variable "project_id" {
  description = "The ID of the project to deploy the infrastructure."
  type        = string
}

variable "region" {
  description = "The region to deploy resources."
  type        = string
}

variable "autoscaler_zone" {
  description = "The zone to provision autoscaler"
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of instances in the autoscaling group."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of instances in the autoscaling group."
  type        = number
}

variable "bucket_name" {
  description = "The name of the GCS bucket containing the HTML file."
  type        = string
}

variable "source_code_path" {
  description = "Path to source code directory that needs to be deployed. If unset, all file in `./src` will be deployed."
  type        = string
  default     = ""
}
