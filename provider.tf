provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.ug60y623Qgz1QcTjq5m3Gtj4"

  address = "https://vault.linuxclaud.com"
}

