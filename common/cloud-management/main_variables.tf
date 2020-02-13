variable "project_name" {
  description = "Project Name"
  default     = "Management Layer Environment Setup"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default     = "mgtlayer"
}

variable "solution_enable" {
  description = "create or delete a solution stack"
  default = {
    "commandcentral" = "true"
    "management"     = "true"
  }
}