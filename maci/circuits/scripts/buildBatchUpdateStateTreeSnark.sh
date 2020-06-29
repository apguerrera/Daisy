#!/bin/bash

cd "$(dirname "$0")"
cd ..
mkdir -p build


# zkutil setup -c build/batchUstCircuit.json -p build/batchUst.params
            # console.log('Generating params file...');
            # shell.exec(zkutilPath + " setup -c " + circuitJsonOut + " -p " + paramsOut );
            # console.log('Exporting proving and verification keys...');
            # shell.exec(zkutilPath + " export-keys -c " + circuitJsonOut + " -p " + paramsOut +
            #     (" --pk " + pkOut + " --vk " + vkOut));
            # console.log("Generated " + paramsOut + ", " + pkOut + " and " + vkOut);

node build/buildSnarks.js -i circom/prod/batchUpdateStateTreeVerifier.circom -j build/batchUstCircuit.json -p build/batchUstPk.json -v build/batchUstVk.json -s build/BatchUpdateStateTreeVerifier.sol -vs BatchUpdateStateTreeVerifier -m build/batchUst.params -z ~/.cargo/bin/zkutil

echo 'Copying BatchUpdateStateTreeVerifier.sol to contracts/sol.'
cp ./build/BatchUpdateStateTreeVerifier.sol ../contracts/sol/
