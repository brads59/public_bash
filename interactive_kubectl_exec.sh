#!/bin/bash
#built for myself and others that can't always remember the syntax and speed of the correct kubectl command to do simple commands... 'df' for example within a pod.
# Prompt for the context
read -p "Enter the Kubernetes context (e.g., live): " context

# Prompt for the namespace
read -p "Enter the namespace: " namespace

# Prompt for the pod name
read -p "Enter the pod name: " pod_name

# Prompt for the command (without /bin/bash -c)
#Too complicated an example # read -p "Enter the command to run inside the pod (e.g., 'pxctl volume inspect pvc-id | egrep \"Name|Size|used\"'): " pod_command
read -p "Enter the command to run inside the pod (e.g., 'df -h'): " pod_command

# Execute the kubectl command with the provided inputs
kubectl --context "$context" --namespace "$namespace" exec "$pod_name" -- /bin/bash -c "$pod_command"

