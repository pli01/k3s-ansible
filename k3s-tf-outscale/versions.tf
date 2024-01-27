terraform {
  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = "0.10.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.3"
    }
  }
}

provider "outscale" {
}

