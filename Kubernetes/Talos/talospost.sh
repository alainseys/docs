#!/bin/bash
validate_ip() {
    local ip="$1"
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
        if (( i1 >= 0 && i1 <= 255 )) && (( i2 >= 0 && i2 <= 255 )) && (( i3 >= 0 && i3 <= 255 )) && (( i4 >= 0 && i4 <= 255 )); then
            return 0  # Valid IP
        fi
    fi
    return 1  # Invalid IP
}

read -p "Please enter the IP address of the control plane: " control_plane_ip
if validate_ip "$control_plane_ip"; then
    echo "Control plane IP address is valid: $control_plane_ip"

    # You can use the control_plane_ip variable in your script below
    # For example, you can print it or use it in a command
    echo "Using control plane IP: $control_plane_ip"

    # Example command using the control plane IP
    # Replace this with your actual command
    echo "Executing command with control plane IP..."
    talosctl --talosconfig talosconfig bootstrap -e $control_plane_ip -n $control_plane_ip
    talosctl --talosconfig talosconfig bootstrap -e $control_plane_ip -n $control_plane_ip
    talosctl --talosconfig talosconfig config endpoint $control_plane_ip
    talosctl --talosconfig talosconfig config node $control_plane_ip
    talosctl --talosconfig talosconfig kubeconfig .
    kubectl --kubeconfig=kubeconfig get nodes
    cp kubeconfig /home/$USER/.kube/config
else
    echo "Invalid IP address format. Please enter a valid IPv4 address."
fi
