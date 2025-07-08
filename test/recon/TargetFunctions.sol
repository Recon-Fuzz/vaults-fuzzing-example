// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

// Targets
import {ManagerTargets} from "./targets/ManagerTargets.sol";
import {VaultTargets} from "./targets/VaultTargets.sol";

abstract contract TargetFunctions is
    VaultTargets,
    ManagerTargets
{}