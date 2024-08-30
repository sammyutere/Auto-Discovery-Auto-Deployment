provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.K5NOLY6oSLxfnqKiVX7Uqa83"

  address = "https://vault.linuxclaud.com"
}

