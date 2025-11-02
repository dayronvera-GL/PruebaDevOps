# network.tf

# ----------------------------------------------------------------------
# 1. Red de VPC y Subredes
# ----------------------------------------------------------------------
resource "google_compute_network" "vpc_network" {
  # El nombre de la VPC utiliza el nombre del entorno (dev/prod)
  name                    = "vpc-${var.environment}-network"
  # Deshabilita la creación automática de subredes
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "subnet-${var.environment}-primary"
  # Asigna el CIDR de la subred utilizando el mapa 'cidr_blocks' basado en el entorno
  ip_cidr_range            = var.cidr_blocks[var.environment]
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  # Permite que las VMs privadas accedan a APIs de Google (ej. GCS, Artifact Registry)
  private_ip_google_access = true 
}

# ----------------------------------------------------------------------
# 2. Cloud NAT (Para VMs privadas)
# ----------------------------------------------------------------------
# Crea un Router Cloud en la región
resource "google_compute_router" "nat_router" {
  name    = "router-${var.environment}"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

# Configura el servicio de Cloud NAT para permitir tráfico saliente
resource "google_compute_router_nat" "nat_config" {
  name                             = "nat-config-${var.environment}"
  router                           = google_compute_router.nat_router.name
  region                           = google_compute_router.nat_router.region
  # Asignación automática de direcciones IP NAT
  nat_ip_allocate_option           = "AUTO_ONLY"
  # Aplica NAT a todas las subredes y rangos IP
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ----------------------------------------------------------------------
# 3. Regla de Firewall para SSH
# ----------------------------------------------------------------------
# Regla que permite el tráfico de entrada SSH (puerto 22) desde cualquier fuente
resource "google_compute_firewall" "allow_ssh_ingress" {
  name    = "allow-ssh-ingress-${var.environment}"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # Permite tráfico de entrada (ingress) desde cualquier IP
  source_ranges = ["0.0.0.0/0"] 
}
