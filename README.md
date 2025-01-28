## Vault Fuzzing Tester

This example is meant to accompany [this post on the Recon substack](https://open.substack.com/pub/getrecon/p/implementing-your-first-few-invariants?r=34r2zr&utm_campaign=post&utm_medium=web) for implementing invariants in an ERC4626 vault. 

This tester was built using the [create-chimera-app](https://github.com/Recon-Fuzz/create-chimera-app/tree/main) template.

### Usage 

Prerequisites:
1. [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
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

  
