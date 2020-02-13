variable "project_name" {
  description = "Project Name"
  default     = "Recipe2 - Software AG Integration simple"
}

variable "resources_name_prefix" {
  description = "Prefix for all resource names"
  default     = "recipe2"
}

variable "solution_enable" {
  description = "create or delete a solution stack"
  default = {
    "management"  = "true"
    "caching"     = "true"
    "integration" = "true"
    "messaging"   = "true"
    "apigateway"  = "true"
  }
}