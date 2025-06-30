// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {
    function property_total_supply_solvency() public {
        uint256 totalSupply = vault.totalSupply();
        address[] memory users = _getActors();

        uint256 sumUserShares;
        for (uint256 i = 0; i < users.length; i++) {
            sumUserShares += vault.balanceOf(users[i]);
        }

        lte(sumUserShares, totalSupply, "sumUserShares must be <= to totalSupply");
    }

    function property_price_per_share_change() public {
        if (currentOperation == OpType.REMOVE) {
            eq(_after.pricePerShare, _before.pricePerShare, "pricePerShare must not change after a remove operation");
        }
    }
}
