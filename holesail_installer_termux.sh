#!/bin/bash

# Check if the environment is Termux
if [ -d "$PREFIX" ] && [ "$(uname -o)" == "Android" ]; then
  echo "Detected Termux environment."
else
  echo "This script is intended to run in Termux only."
  exit 1
fi

# Step 2: Clone the Holesail repository
if [ ! -d "holesail" ]; then
  echo "Cloning the Holesail repository..."
  git clone https://github.com/holesail/holesail.git
else
  echo "Holesail repository already cloned."
fi

# Navigate into the Holesail directory
cd holesail || { echo "Failed to enter the Holesail directory."; exit 1; }

# Step 3: Run npm install
echo "Installing dependencies..."
npm install || { echo "npm install failed."; exit 1; }

# Step 4: Install 'bare' globally
echo "Installing 'bare' globally..."
npm install -g bare || { echo "Failed to install 'bare' globally."; exit 1; }

# Step 5: Run the project with 'bare index.js'
echo "Running Holesail with 'bare index.js'..."
bare index.js || { echo "Failed to run Holesail with 'bare index.js'."; exit 1; }

echo "Setup complete. Holesail is running!"
