# =============================================================================
# 1. СЕТЬ (VPC)
# Виртуальное изолированное пространство. Аналог "участка" или "здания".
# =============================================================================
resource "yandex_vpc_network" "main" {
  name = "${var.flow}-network"
  
  # labels нужны для поиска и фильтрации в консоли/скриптах
  labels = {
    project   = "netology-hw-09"
    managed-by = "terraform"
  }
}

# =============================================================================
# 2. ПОДСЕТИ
# Делят сеть на логические сегменты. Одна подсеть = одна зона доступности.
# Используем count, чтобы не копировать блоки руками.
# =============================================================================
resource "yandex_vpc_subnet" "main" {
  count          = length(var.zones) # Создадим ровно столько подсетей, сколько зон в списке
  
  name           = "${var.flow}-subnet-${replace(var.zones[count.index], "-", "")}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.main.id # 🔗 Привязка к сети выше
  v4_cidr_blocks = [var.subnet_cidrs[count.index]]
  
  labels = {
    zone = var.zones[count.index]
  }
}

# =============================================================================
# 3. ГРУППА БЕЗОПАСНОСТИ (Security Group)
# Это Виртуальный файервол. Он НЕ содержит интерфейсы или ВМ.
# Он только описывает: "Что можно пропускать внутрь/наружу".
# Применяется к интерфейсам ВМ через security_group_ids.
# =============================================================================
resource "yandex_vpc_security_group" "main" {
  name       = "${var.flow}-sg"
  network_id = yandex_vpc_network.main.id # 🔗 Должна жить внутри той же сети

  # Входящие правила (ingress)
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH access for admin"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP traffic for web"
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Ping diagnostics"
  }

  # Исходящие правила (egress) - разрешаем всё наружу (для apt, curl, healthchecks)
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outbound traffic"
  }
}