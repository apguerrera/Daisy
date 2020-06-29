#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ..
echo 'Building contracts'

# Delete old files
rm -rf ./compiled/*

mkdir -p ./compiled/abis

# Copy the Semaphore contracts from the submodule into solidity/

npx etherlime compile --buildDirectory=compiled --workingDirectory=sol --exportAbi --runs 200 --solc-version 0.5.14

# Build the Poseidon contract from bytecode
node build/buildPoseidon.js
