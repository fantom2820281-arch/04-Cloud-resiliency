# =============================================================================
# 1. СЕТЬ
# =============================================================================
resource "yandex_vpc_network" "main" {
  name = "${var.flow}-network"
  labels = { project = "netology-hw-09", managed-by = "terraform" }
}

# =============================================================================
# 2. УПРАВЛЯЕМЫЙ CLOUD NAT
# Не требует создания ВМ, масштабируется сам, не светит IP бэкендов
# =============================================================================
resource "yandex_vpc_gateway" "nat_gw" {
  name = "${var.flow}-nat-gateway"
  shared_egress_gateway {}
}

# =============================================================================
# 3. ТАБЛИЦА МАРШРУТИЗАЦИИ
# Говорит подсетям: "всё, что не локальное → шлюй на NAT"
# =============================================================================
resource "yandex_vpc_route_table" "nat_rt" {
  name       = "${var.flow}-nat-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gw.id
  }
}

# =============================================================================
# 4. ПОДСЕТИ (с привязкой к таблице маршрутизации)
# =============================================================================
resource "yandex_vpc_subnet" "main" {
  count          = length(var.zones)
  name           = "${var.flow}-subnet-${replace(var.zones[count.index], "-", "")}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidrs[count.index]]
  
  # 🔥 КЛЮЧЕВАЯ СТРОКА: подсети теперь знают про NAT
  route_table_id = yandex_vpc_route_table.nat_rt.id
}

# =============================================================================
# 5. ГРУППА БЕЗОПАСНОСТИ (без изменений, egress ANY уже разрешён)
# =============================================================================
resource "yandex_vpc_security_group" "main" {
  name       = "${var.flow}-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH access"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP access"
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Ping diagnostics"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outbound traffic"
  }
}