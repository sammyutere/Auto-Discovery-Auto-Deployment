# terraform {
#   backend "s3" {
#     bucket         = "set19-remote-tf"
#     key            = "set19/tfstate"
#     dynamodb_table = "petclinic"
#     region         = "eu-west-3"
#     encrypt        = true
#     # profile        = "set19"
#   }
# }