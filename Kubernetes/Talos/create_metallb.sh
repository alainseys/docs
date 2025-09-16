#!/bin/bash

# Function to create the configuration file
create_ip_file() {
    local ip_address_range="$1"
    local filename="metallb.yaml"

    # Define the content with the placeholder [IP] and [CLUSTER_NAME]
    cat <<EOL > "$filename"
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $ip_address_range
EOL

    echo "Configuration file '$filename' created with range: $ip_address_range"
}

# Main script execution
read -p "Please enter the ip range:(example 192.168.10.1-192.168.1.20) " ip_address_range


# Validate the IP address (basic validation)
create_ip_file $ip_address_range
