// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import {VaultTargets} from "test/recon/targets/VaultTargets.sol";


contract CryticToFoundry is Test, VaultTargets, FoundryAsserts {
    function setUp() public {
        setup();
    }

    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }
}
