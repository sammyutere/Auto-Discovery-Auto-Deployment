provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.2g3d0mdd2qywawLCv0izk9Vc"

  address = "https://vault.linuxclaud.com"
}

