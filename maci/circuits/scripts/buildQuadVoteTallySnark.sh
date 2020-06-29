#!/bin/bash

cd "$(dirname "$0")"
cd ..
mkdir -p build

# zkutil setup -c build/qvtCircuit.json -p build/qvt2.params

# zkutil export-keys -c build/qvtCircuit.json -p build/qvt2.params  --pk build/qvt2Pk.bin  --vk  build/qvt2Vk.json
 
#  export-keys 
#                 (" --pk " + pkOut + " --vk " + vkOut

node build/buildSnarks.js -i circom/prod/quadVoteTally.circom -j build/qvtCircuit.json -p build/qvtPk.bin -v build/qvtVk.json -s build/QuadVoteTallyVerifier.sol -vs QuadVoteTallyVerifier -m build/qvt.params -z ~/.cargo/bin/zkutil

echo 'Copying QuadVoteTallyVerifier.sol to contracts/sol.'
cp ./build/QuadVoteTallyVerifier.sol ../contracts/sol/
