output "lb_ip" {
  description = "Внешний IP сетевого балансировщика"
  value = one(flatten([
    for l in yandex_lb_network_load_balancer.nlb.listener :
    [for spec in tolist(l.external_address_spec) : spec.address]
  ]))
}