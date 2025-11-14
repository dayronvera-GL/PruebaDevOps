# Define un recurso de Compute Engine que actuará como nuestro servidor web.

resource "google_compute_instance" "web_server" {
  # El nombre de la instancia se compone del nombre base y el entorno (dev/qa/prod)
  name         = "web-server-${var.environment}"
  # AHORA USA EL MAPA 'vm_machine_type' y accede al valor del entorno actual.
  machine_type = var.vm_machine_type[var.environment] 
  zone         = "us-central1-a"
  project      = var.project_id

  # Configuración del disco de arranque (Boot disk)
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Usamos una imagen ligera de Debian 11
    }
  }

  # Configuración de la interfaz de red
  network_interface {
    # La instancia se conecta a la red VPC y subred que creamos en network.tf
    # NOTA: ASUMO QUE network.tf utiliza el mismo patrón de variables (mapas)
    subnetwork = google_compute_subnetwork.subnetwork.id

    # No tiene IP pública, ya que accederá a Internet a través de Cloud NAT
    # access_config {} es necesaria para que Cloud NAT funcione
    access_config {
      # Dejamos 'nat_ip' vacío para que GCP asigne automáticamente la IP a través de NAT
    }
  }

  # Metadatos de inicio para instalar un servidor web básico
  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl enable apache2
    echo "<h1>Web Server en ${var.environment} (Desplegado via Terraform CI/CD. Prueba1 $(date +%Y-%m-%d))</h1>" | sudo tee /var/www/html/index.html
    sudo systemctl start apache2
  EOF
  # Tags de red para que las reglas de firewall apliquen a esta instancia
  tags = ["http-server", "ssh"]
}

# --------------------------------------------------------------------------------------------------
# Regla de Firewall para permitir el tráfico HTTP a la instancia
# --------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "allow_http_ingress" {
  name    = "allow-http-ingress-${var.environment}"
  # Asumo que la red VPC se llama 'vpc_network' en otro archivo (e.g., network.tf)
  network = google_compute_network.vpc_network.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  # Aplica esta regla a cualquier instancia que tenga el tag "http-server"
  target_tags   = ["http-server"]
}
