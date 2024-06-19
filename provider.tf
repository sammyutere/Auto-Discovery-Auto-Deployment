provider "aws" {
  region = "eu-west-3"
  profile = "lead"
}

resource "null_resource" "vault_setup" {
  // Trigger script execution on Terraform apply
  
  provisioner "local-exec" {
    command = "export VAULT_TOKEN=$(cat ./vault/root_token.txt | tr -d '[:space:]')"
  }
  
}
data "null_data_source" "vault_dependency" {
  depends_on = [null_resource.vault_setup]
  inputs = {
    token = var.VAULT_TOKEN
  }
}
locals {
  token = var.VAULT_TOKEN
}
provider "vault" {
  token = local.token
  address = "https://vault.greatminds.sbs"
}

