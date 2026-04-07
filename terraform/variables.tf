variable "flow" {
  type    = string
  default = "dima"
}

variable "cloud_id" {
  type    = string
  default = "b1g8isi2f9nvjnsjt5co"
}

variable "folder_id" {
  type    = string
  default = "b1g8c3dr0g4j4rcnj30o"
}

variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b"]
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["192.168.10.0/24", "192.168.20.0/24"]
}