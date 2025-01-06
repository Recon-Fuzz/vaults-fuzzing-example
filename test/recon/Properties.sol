// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {

    modifier checks() {
        _;
        property_price_per_share();
    }
    
    // Public property that gets checked randomly by the fuzzer
    function property_share_solvency() public {
        lte(_after.ghostTotalShares, _after.vaultTotalShares, "ghostTotalShares must be less than or equal to vaultTotalShares");
    }
    
    // Internal property that only gets checked for handlers that use the checks modifier
    function property_price_per_share() internal {
        eq(_after.pricePerShare, _after.pricePerShare, "pricePerShare should not change");
    }
}
