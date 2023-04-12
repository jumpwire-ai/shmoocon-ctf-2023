terraform {
  required_version = ">= 1.0.9"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }

    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.0.20"
    }
  }
}


variable "name" {
  type = string
}

locals {
  fly_app  = "ctf-${var.name}"
  hostname = "${var.name}.ctf"
  dns_suffix = "changeme"
}

data "cloudflare_zone" "ctf_root" {
  name = local.dns_suffix
}

data "fly_app" "app" {
  name = local.fly_app
}

resource "fly_cert" "app" {
  app      = data.fly_app.app.id
  hostname = "${local.hostname}.${data.cloudflare_zone.ctf_root.name}"
}

resource "cloudflare_record" "fly_app" {
  zone_id = data.cloudflare_zone.ctf_root.id
  name    = local.hostname
  value   = "${data.fly_app.app.id}.fly.dev"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}
