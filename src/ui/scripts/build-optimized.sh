#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Optimized React build script for IDP Pattern 2 UI
# This script addresses memory issues and build performance problems
# that can occur with the standard npm run build command.

set -e

echo "=== Optimized React Build for IDP Pattern 2 ==="
echo "Starting optimized build process..."
echo

# Check if we're in the UI directory
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found. Please run this script from the src/ui directory."
  exit 1
fi

# Check for required environment file
if [ ! -f ".env.production" ]; then
  echo "Warning: .env.production file not found."
  echo "Make sure to create it with the necessary environment variables."
  echo
fi

# Clean previous build
echo "Step 1: Cleaning previous build..."
rm -rf build/
echo "✓ Previous build cleaned"
echo

# Install dependencies if node_modules is missing
if [ ! -d "node_modules" ]; then
  echo "Step 2: Installing dependencies..."
  npm ci
  echo "✓ Dependencies installed"
  echo
else
  echo "Step 2: Dependencies already installed"
  echo
fi

# Build with optimizations to prevent memory issues and improve performance
echo "Step 3: Building React application with optimizations..."
echo "Build flags:"
echo "  - GENERATE_SOURCEMAP=false (reduces build size and time)"
echo "  - INLINE_RUNTIME_CHUNK=false (prevents inlining issues)"
echo "  - NODE_OPTIONS=--max-old-space-size=4096 (increases memory limit)"
echo

# Export environment variables for the build
export GENERATE_SOURCEMAP=false
export INLINE_RUNTIME_CHUNK=false
export NODE_OPTIONS="--max-old-space-size=4096"

# Run the build
if npm run build; then
  echo
  echo "✓ Build completed successfully"
  
  # Display build information
  echo
  echo "Build Summary:"
  echo "  Build directory: $(pwd)/build"
  echo "  Total files: $(find build -type f | wc -l)"
  echo "  Build size: $(du -sh build | cut -f1)"
  
  # List main build artifacts
  echo
  echo "Main build artifacts:"
  ls -lh build/static/js/ 2>/dev/null | head -10
  ls -lh build/static/css/ 2>/dev/null | head -5
  
  echo
  echo "=== Build Complete ==="
  echo "The build folder is ready to be deployed."
  echo
  echo "Next steps:"
  echo "1. Deploy to S3: aws s3 sync build/ s3://YOUR_WEB_BUCKET --delete --region YOUR_REGION"
  echo "2. Create CloudFront invalidation if needed"
  
else
  echo
  echo "✗ Build failed"
  echo
  echo "Common solutions:"
  echo "1. Clear npm cache: npm cache clean --force"
  echo "2. Delete node_modules and reinstall: rm -rf node_modules && npm install"
  echo "3. Check for syntax errors: npm run lint"
  echo "4. Ensure all dependencies are compatible"
  
  exit 1
fi