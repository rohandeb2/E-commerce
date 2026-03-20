#!/bin/bash

# Define the root directory name
REPO_NAME="easyshop-manifests"

echo "🗑️  Deleting the GitOps structure for $REPO_NAME..."

# List of top-level folders to delete
FOLDERS=(
  "argocd"
  "helm/easyshop-app"
  "bootstrap/ingress-controller"
  "bootstrap/external-secrets"
)

# Delete each folder if it exists
for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    rm -rf "$folder"
    echo "Deleted: $folder"
  else
    echo "Not found, skipping: $folder"
  fi
done

# Optionally delete parent bootstrap folder if empty
if [ -d "bootstrap" ] && [ ! "$(ls -A bootstrap)" ]; then
  rmdir bootstrap
  echo "Deleted empty folder: bootstrap"
fi

echo "✅ GitOps structure deleted successfully!"