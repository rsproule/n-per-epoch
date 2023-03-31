all: install build
# Install forge dependencies (not needed if submodules are already initialized).
install:; forge install && npm install
# Build contracts and inject the Poseidon library.
build:; forge build && ts-node ./src/test/scripts/generate-circom-lib.ts
# Run tests, with debug information and gas reports.
test:; forge test -vvv --gas-report
# Update forge dependencies.
update:; forge update
# Deploy contracts
deploy:; ts-node --no-warnings scripts/deploy.js
