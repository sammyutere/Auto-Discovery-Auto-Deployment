provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.9bnCkJtuwMqD2QR58EQBtooB"

  address = "https://vault.linuxclaud.com"
}

