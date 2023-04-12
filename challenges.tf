locals {
  fly_config = yamldecode(file("~/.fly/config.yml"))

  # Extra vars for the self-reflection challenge
  graphql_domain = "changeme.hasura.app"
  graphql_prefix = "fusion"
  api_prefix     = "dev.edge"
}

provider "fly" {
  fly_api_token = local.fly_config.access_token
}

variable "challenges" {
  type = set(string)
  default = [
    "jwt",
    "wiki",
    "blog",
    "penguin",
    "self-reflection",
    "green-thumb",
    "pwn",
    "cannaregio",
    "bot-script",
  ]
}

module "challenges" {
  for_each = var.challenges
  source   = "./modules/challenge"
  name     = each.value
}

resource "cloudflare_record" "self_reflection_api" {
  zone_id = data.cloudflare_zone.ctf_root.id
  name    = "${local.api_prefix}.ctf"
  value   = "self-reflection.ctf.${data.cloudflare_zone.ctf_root.name}"
  type    = "CNAME"
  ttl     = "3600"
  proxied = false
}

resource "cloudflare_record" "self_reflection_graphql" {
  zone_id = data.cloudflare_zone.ctf_root.id
  name    = "${local.graphql_prefix}.ctf"
  value   = local.graphql_domain
  type    = "CNAME"
  ttl     = "3600"
  proxied = false
}

data "fly_app" "self_reflection_api" {
  name = "ctf-self-reflection"
}

resource "fly_cert" "appself_reflection_api" {
  app      = data.fly_app.self_reflection_api.id
  hostname = "${local.api_prefix}.ctf.${data.cloudflare_zone.ctf_root.name}"
}

resource "cloudflare_record" "cloud-proxy" {
  zone_id = data.cloudflare_zone.ctf_root.id
  name    = "cloud-proxy.ctf"
  value   = "changeme"
  type    = "A"
  ttl     = "3600"
  proxied = false
}
