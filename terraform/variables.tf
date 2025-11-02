# variables.tf

variable "project_id" {
  description = "El ID del proyecto de GCP."
  type        = string
}

variable "region" {
  description = "La región principal para desplegar los recursos."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Define el entorno de despliegue: 'dev' o 'prod'."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El valor de 'environment' debe ser 'dev' o 'prod'."
  }
}

variable "vm_machine_type" {
  description = "Mapa de tipos de máquina por entorno."
  type = map(string)
  default = {
    dev  = "e2-standard-2" 
    prod = "n2-standard-4" 
  }
}

variable "disk_type" {
  description = "Mapa de tipos de disco persistente por entorno."
  type = map(string)
  default = {
    dev  = "pd-standard" 
    prod = "pd-ssd"      
  }
}