output "key_pair_id" {
  description = "The key pair ID"
  value       = module.key_pair.key_pair_id
}

output "public_key_pem" {
  description = "Public key data in PEM (RFC 1421) format"
  value       = module.key_pair.public_key_pem