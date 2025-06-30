// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {
    
    // Public property that gets checked randomly by the fuzzer
    function property_share_solvency() public {
        lte(_after.ghostTotalShares, _after.vaultTotalShares, "ghostTotalShares must be less than or equal to vaultTotalShares");
    }

    function property_total_supply_solvency() public {
        uint256 totalSupply = vault.totalSupply();
        address[] memory users = _getActors();

        uint256 sumUserShares;
        for (uint256 i = 0; i < users.length; i++) {
            sumUserShares += vault.balanceOf(users[i]);
        }

        lte(sumUserShares, totalSupply, "sumUserShares must be <= to totalSupply");
    }

}
