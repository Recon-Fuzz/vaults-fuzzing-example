
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is Properties, BaseTargetFunctions {

    function eRC4626Tester_approve(address spender, uint256 value) updateBeforeAfter checks public {
        eRC4626Tester.approve(spender, value);
    }
    
    function eRC4626Tester_transfer(address to, uint256 value) updateBeforeAfter checks public {
        eRC4626Tester.transfer(to, value);
    }

    function eRC4626Tester_deposit(uint256 assets, address receiver) updateBeforeAfter public {        
        eRC4626Tester.deposit(assets, receiver);
    }

    function eRC4626Tester_mint(uint256 shares, address receiver) updateBeforeAfter public {
        uint256 expectedAssets = eRC4626Tester.previewMint(shares);
        uint256 vaultBalanceBefore = underlyingAsset.balanceOf(address(this));
        
        eRC4626Tester.mint(shares, receiver);
        
        uint256 vaultBalanceAfter = underlyingAsset.balanceOf(address(this));
        eq(vaultBalanceAfter, vaultBalanceBefore + expectedAssets, "vaultBalanceAfter must increase by expectedAssets amount");
    }

    function eRC4626Tester_redeem(uint256 shares, address receiver, address owner) updateBeforeAfter public {
        uint256 totalSupplyBefore = eRC4626Tester.totalSupply();
        
        eRC4626Tester.redeem(shares, receiver, owner);

        uint256 totalSupplyAfter = eRC4626Tester.totalSupply();
        eq(totalSupplyAfter, totalSupplyBefore - shares, "totalSupplyAfter must decrease by shares amount");
    }

    function eRC4626Tester_withdraw(uint256 assets, address receiver, address owner) updateBeforeAfter public {
        eRC4626Tester.withdraw(assets, receiver, owner);
    }
}