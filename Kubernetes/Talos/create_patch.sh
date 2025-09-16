#!/bin/bash

# Function to create the configuration file
create_ip_file() {
    local ip_address="$1"
    local cluster_name="$2"
    local filename="cp.patch.yaml"

    # Define the content with the placeholder [IP] and [CLUSTER_NAME]
    cat <<EOL > "$filename"
- op: add
  path: /machine/network
  value:
    interfaces:
    - interface: eth0
      dhcp: true
      vip:
        ip: $ip_address

EOL

    echo "Configuration file '$filename' created with IP: $ip_address and Cluster Name: $cluster_name"
}

# Main script execution
# Check if controlplane.yaml, worker.yaml, and talosconfig exist and delete them if they do
if [ -f "controlplane.yaml" ]; then
    rm "controlplane.yaml"
    echo "Deleted existing controlplane.yaml"
fi

if [ -f "worker.yaml" ]; then
    rm "worker.yaml"
    echo "Deleted existing worker.yaml"
fi

if [ -f "talosconfig" ]; then
    rm "talosconfig"
    echo "Deleted existing talosconfig"
fi

read -p "Please enter the IP address: " ip_address
read -p "Please enter the Cluster Name: " cluster_name

# Validate the IP address (basic validation)
if [[ "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip_address"
    if (( i1 >= 0 && i1 <= 255 )) && (( i2 >= 0 && i2 <= 255 )) && (( i3 >= 0 && i3 <= 255 )) && (( i4 >= 0 && i4 <= 255 )); then
        create_ip_file "$ip_address" "$cluster_name"
        talosctl gen config "$cluster_name" "https://$ip_address:6443" --config-patch-control-plane @cp.patch.yaml
    else
        echo "Invalid IP address. Each octet must be between 0 and 255."
    fi
else
    echo "Invalid IP address format. Please enter a valid IPv4 address."
fi
