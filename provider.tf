provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

provider "vault" {
  token = "s.DixUE4cF3Ql9KnwNTBQcE8Fs"

  address = "https://vault.linuxclaud.com"
}

