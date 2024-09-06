provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.dOTggvbhROH7NacmUvhru2Qo"

  address = "https://vault.linuxclaud.com"
}

