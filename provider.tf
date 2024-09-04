provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.YhxfDNaFpI9Bu9UGmB6x8gTi"

  address = "https://vault.linuxclaud.com"
}

