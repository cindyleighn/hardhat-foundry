# Sample Hardhat Project using Foundry for extended testing

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.  It also includes a sample contract from the Foundry sample project, including tests.

The hardhat-preprocessor dependency is required to wire hardhat and foundry.  
Changes to the hardhat.config.ts file have been made to achieve this, including the addition of files required to run Foundry tests:
- lib/forge-std
- foundry.toml
- remappings.txt

# Install Foundry 

Get foundry:
```
curl -L https://foundry.paradigm.xyz | bash
```

Install foundry:
```
foundryup
```

# Try it out

Try running some of the following tasks:

```shell
yarn hardhat compile
yarn hardhat test
forge test
```
