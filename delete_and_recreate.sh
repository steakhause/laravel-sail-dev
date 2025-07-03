#!/bin/bash

set -euo pipefail

PROJECT_DIR="$(pwd)"
SRC_DIR="$PROJECT_DIR/src"

echo "⚠️  WARNING:"
echo "This script will PERMANENTLY DELETE all Laravel project files in:"
echo "  $SRC_DIR"
echo "and recreate the container as new."
echo

read -rp "Are you sure you want to continue? [y/N]: " confirm
case "$confirm" in
  [yY][eE][sS] | [yY])
    echo "✅ Proceeding..."
    
    cd "$PROJECT_DIR" || {
      echo "❌ Failed to cd into $PROJECT_DIR"
      exit 1
    }

    echo "🛑 Shutting down Docker containers..."
    docker compose down

    echo "🧹 Wiping project files..."
    sudo rm -rf "$SRC_DIR"/*
    sudo find "$SRC_DIR" -mindepth 1 -maxdepth 1 -name ".*" ! -name "." ! -name ".." -exec rm -rf {} +

    echo "🧱 Recreating Laravel project..."
    docker run --rm -v "$SRC_DIR":/app composer create-project laravel/laravel /app

    echo "🚀 Bringing containers back up..."
    docker compose up -d

    echo "✅ Done. Laravel project has been reset."
    ;;
  *)
    echo "👍 Canceled. No changes made."
    exit 0
    ;;
esac
