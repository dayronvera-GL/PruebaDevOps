# main.tf

# ----------------------------------------------------------------------
# 1. Backend: Almacenamiento Remoto de Estado (Cloud Storage)
# La configuración del bucket se pasa desde cloudbuild.yaml.
# ----------------------------------------------------------------------
terraform {
  backend "gcs" {
    # El nombre del bucket es inyectado por Cloud Build (backend-config)
    # La ruta asegura que el estado se aísle por workspace (dev o prod)
    prefix  = "terraform/state" 
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ----------------------------------------------------------------------
# 2. Configuración del Proveedor GCP
# ----------------------------------------------------------------------
provider "google" {
  # project_id y region son pasados como variables desde Cloud Build.
  project = var.project_id 
  region  = var.region
}
