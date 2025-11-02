# network.tf

# ----------------------------------------------------------------------
# 1. Red de VPC y Subredes
# ----------------------------------------------------------------------
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-${var.environment}-network"
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "subnet-${var.environment}-primary"
  # Asigna un CIDR diferente basado en el entorno (DEV: 10.10.x, PROD: 10.20.x)
  ip_cidr_range = var.environment == "dev" ? "10.10.1.0/24" : "10.20.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true 
}

# ----------------------------------------------------------------------
# 2. Cloud NAT (Para VMs privadas)
# ----------------------------------------------------------------------
resource "google_compute_router" "nat_router" {
  name    = "router-${var.environment}"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "nat-config-${var.environment}"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ----------------------------------------------------------------------
# 3. Regla de Firewall para SSH
# ----------------------------------------------------------------------
resource "google_compute_firewall" "allow_ssh_ingress" {
  name    = "allow-ssh-ingress-${var.environment}"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] 
}