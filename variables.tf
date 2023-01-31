variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "env" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "service_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "subnet_ids" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
}

variable "certificate_arn" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "domain" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "container_port" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "80"
}

variable "sg_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default     = null
}

variable "cidr_ingress" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = list(string)
  default     = null
}

variable "is_https" {
  description = "Enable https"
  type        = bool
  default     = false
}
