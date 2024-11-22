#!/bin/bash
#A quick script to grab values of every deployment, configmap , etc... in the case of an emergency and to quickly try and re-deploy
#Questions see Brad Shope

# Define the base backup directory
BASE_BACKUP_DIR="./k8s-backups"

# Resources to back up
RESOURCES=("deployments" "configmaps" "secrets" "services" "ingresses")

# Create the base backup directory if it doesn't exist
mkdir -p "$BASE_BACKUP_DIR"

# Get all namespaces
NAMESPACES=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for NAMESPACE in $NAMESPACES; do
  echo "Processing namespace: $NAMESPACE"

  # Create a directory for the namespace
  NAMESPACE_BACKUP_DIR="$BASE_BACKUP_DIR/$NAMESPACE"
  mkdir -p "$NAMESPACE_BACKUP_DIR"

  # Loop through each resource type
  for RESOURCE in "${RESOURCES[@]}"; do
    echo "Backing up $RESOURCE in namespace: $NAMESPACE"

    # Create a subdirectory for the resource type
    RESOURCE_BACKUP_DIR="$NAMESPACE_BACKUP_DIR/$RESOURCE"
    mkdir -p "$RESOURCE_BACKUP_DIR"

    # Get all items of the resource type in the namespace
    ITEMS=$(kubectl get "$RESOURCE" -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)

    # Check if there are any items of this resource type
    if [ -z "$ITEMS" ]; then
      echo "No $RESOURCE found in namespace '$NAMESPACE'. Skipping."
      continue
    fi

    # Backup each item
    for ITEM in $ITEMS; do
      echo "Backing up $RESOURCE: $ITEM in namespace: $NAMESPACE"
      kubectl get "$RESOURCE" "$ITEM" -n "$NAMESPACE" -o yaml > "$RESOURCE_BACKUP_DIR/${ITEM}_backup.yaml"
      if [ $? -eq 0 ]; then
        echo "Backup of $RESOURCE $ITEM in namespace $NAMESPACE completed successfully."
      else
        echo "Failed to backup $RESOURCE $ITEM in namespace $NAMESPACE."
      fi
    done
  done
done

echo "All resources have been backed up. Backups are stored in $BASE_BACKUP_DIR."

