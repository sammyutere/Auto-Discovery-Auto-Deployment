
# #!/bin/bash
# sleep 20
# # Define the Vault server details

# SSH_USER="ubuntu"
# SSH_KEY="./vault-private-key" # Optional, if using passwordless login

# # Function to generate a random password
# generate_random_password() {
#     openssl rand -base64 16
# }

# # Function to run Vault commands on the remote server
# run_vault_commands() {
#     ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$VAULT_SERVER_IP" << EOF
# # Initialize Vault
# init_output=\$(vault operator init -format=json)

# # Capture the root token
# root_token=\$(echo \$init_output | jq -r '.root_token')

# # Save the root token to a file (optional, for reference)
# echo \$root_token > root_token.txt

# # Log in to Vault using the root token
# vault login \$root_token

# # Enable KV secrets engine at the specified path
# vault secrets enable -path=secret/ kv

# # Generate a random password
# random_password=\$(openssl rand -base64 16)

# # Store username and random password in the KV secrets engine
# vault kv put secret/database username=admin password=\$random_password

# echo "Vault setup completed successfully with a random password."
# echo "Generated random password: \$random_password"
# EOF

#     # Securely copy the root token file from the remote server to the local machine
#     scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$VAULT_SERVER_IP:root_token.txt" .
# }

# # Capture the Vault server IP from Terraform output
# VAULT_SERVER_IP=$(terraform output -raw vault_server_public_ip)

# # Run the function to SSH into the Vault server and execute the Vault commands
# run_vault_commands
