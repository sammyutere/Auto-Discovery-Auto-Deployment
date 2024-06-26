provider "aws" {
  region = "eu-west-3"
  profile = "lead"
}

provider "vault" {
  token = "s.RRMqzgqnJjH1jsiBjxhCCZsp"

  address = "https://vault.greatminds.sbs"
}

