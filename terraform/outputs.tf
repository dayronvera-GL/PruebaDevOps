# --------------------------------------------------------------------------------------------------
# OUTPUTS
# Define los valores que se mostrarán después de que Terraform aplique los cambios.
# --------------------------------------------------------------------------------------------------

output "vm_instance_name" {
  description = "Nombre de la instancia de Compute Engine."
  value       = google_compute_instance.web_server.name
}

output "vm_internal_ip" {
  description = "Dirección IP interna (privada) de la instancia de Compute Engine."
  value       = google_compute_instance.web_server.network_interface[0].network_ip
}

output "network_name" {
  description = "Nombre de la Red VPC."
  value       = google_compute_network.vpc_network.name
}
