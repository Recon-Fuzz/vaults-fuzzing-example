// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {CryticAsserts} from "@chimera/CryticAsserts.sol";
import {VaultTargets} from "test/recon/targets/VaultTargets.sol";

// echidna . --contract CryticTester --config echidna.yaml
// medusa fuzz
contract CryticTester is VaultTargets, CryticAsserts {
    constructor() payable {
        setup();
    }
}
