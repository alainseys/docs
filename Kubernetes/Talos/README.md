# Talos Installation Instructions

This guide provides manual installation instructions for Talos. Automation scripts are in development.

## Installation Steps

1. **Install `govc`**  
   Follow the instructions in the [govc README](https://github.com/vmware/govmomi/blob/main/govc/README.md) to install `govc`.

2. **Run the Patch Creation Script**  
   Execute the script to create necessary patches (ensure the script is available in your environment).

3. **Upload OVA to vCenter**  
   ```bash
   ./vmware.sh upload_ova
   ```

4. **Create the Cluster**  
   ```bash
   ./vmware.sh create
   ```

5. **Install `talosctl`**  
   Refer to the [Talos documentation](https://www.talos.dev/v1.9/talos-guides/install/talosctl/) for installing `talosctl`.

6. **Run Post-Installation Script**  
   Execute the `talos_post.sh` script to complete setup.

7. **Verify Cluster Nodes**  
   Check the status of the cluster nodes:  
   ```bash
   kubectl --kubeconfig=kubeconfig get nodes
   ```

## MetalLB Configuration

1. **Verify Namespace**  
   Confirm the `metallb-system` namespace exists:  
   ```bash
   kubectl get namespaces
   ```

2. **Install MetalLB Manifest**  
   Apply the MetalLB native manifest:  
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
   ```

3. **Define IP Address Pool**  
   Create a file named `ipaddresses.yaml` with the following content:  
   ```yaml
   apiVersion: metallb.io/v1beta1
   kind: IPAddressPool
   metadata:
     name: first-pool
     namespace: metallb-system
   spec:
     addresses:
       - 10.1.149.240-10.1.149.250
   ```

4. **Define Layer 2 Advertisement**  
   Create a file named `layer2.yaml` with the following content:  
   ```yaml
   apiVersion: metallb.io/v1beta1
   kind: L2Advertisement
   metadata:
     name: first-pool
     namespace: metallb-system
   ```

5. **Apply Configuration**  
   Apply both configuration files:  
   ```bash
   kubectl create -f ipaddresses.yaml
   kubectl create -f layer2.yaml
   ```

6. **Verify IP Address Pool**  
   Check the MetalLB IP address pool:  
   ```bash
   kubectl get ipaddresspools.metallb.io -A
   ```

7. **Test the Setup**  
   Deploy and expose an Nginx service to verify LoadBalancer functionality:  
   ```bash
   kubectl create deploy nginx --image nginx:latest
   kubectl expose deploy nginx --port 80 --type LoadBalancer
   kubectl get service | grep nginx
   ```