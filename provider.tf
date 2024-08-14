provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.wHfAEgke7FyErbKrN0Dm6FYR"

  address = "https://vault.linuxclaud.com"
}

