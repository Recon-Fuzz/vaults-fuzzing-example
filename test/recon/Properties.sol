// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {Asserts} from "@chimera/Asserts.sol";

import {BeforeAfter} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {

    // @dev Property: Total assets should always equal the sum of all depositors' claimable assets
    // NOTE: This detects when precision loss allows attackers to claim more than they deposited
    function property_totalAssetsEqualSumOfClaims() public {
        uint256 totalClaimable = 0;

        address[] memory actors = _getActors();
        
        // Sum up what each holder can claim based on their shares
        for (uint256 i = 0; i < actors.length; i++) {
            address actor = actors[i];
            uint256 shares = vault.balanceOf(actor);
            totalClaimable += vault.convertToAssets(shares);
        }
        
        uint256 actualAssets = vault.totalAssets();
        
        // if vault has more assets than the sum of all depositors' claimable assets, some depositors have lost their funds
        lte(actualAssets, totalClaimable, "totalAssets should equal totalClaimable");
    }

}
