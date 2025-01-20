## Vault Fuzzing Tester

This example is meant to accompany the post on the Recon substack for implementing invariants in an ERC4626 vault. 

This tester was built using the [create-chimera-app](https://github.com/Recon-Fuzz/create-chimera-app/tree/main) template.

### Usage 

Prerequisites:
1. [Foundry] installed
2. [Echidna](https://github.com/crytic/echidna) and/or [Medusa](https://github.com/crytic/medusa) installed 

#### Echidna

To run the Echidna fuzzer use the following command from the root directory: 
```terminal
echidna . --contract CryticTester --config echidna.yaml
```

#### Medusa 

To run the Medusa fuzzer use the following command from the root directory: 
```terminal
medusa fuzz
```

  
