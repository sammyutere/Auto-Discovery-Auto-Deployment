output "pub_key_pair_id" {
  description = "The key pair ID"
  value       = aws_key_pair.public_key.id
}

output "private_key_pem" {
  description = "Public key data in PEM (RFC 1421) format"
  value       = tls_private_key.keypair.private_key_pem
}