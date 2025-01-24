
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is Properties, BaseTargetFunctions {

    function vault_approve(address spender, uint256 value) updateBeforeAfter checks public {
        vault.approve(spender, value);
    }
    
    function vault_transfer(address to, uint256 value) updateBeforeAfter checks public {
        vault.transfer(to, value);
    }

    function vault_deposit(uint256 assets, address receiver) updateBeforeAfter public {        
        vault.deposit(assets, receiver);
    }

    function vault_mint(uint256 shares, address receiver) updateBeforeAfter public {
        uint256 expectedAssets = vault.previewMint(shares);
        uint256 vaultBalanceBefore = underlyingAsset.balanceOf(address(this));
        
        vault.mint(shares, receiver);
        
        uint256 vaultBalanceAfter = underlyingAsset.balanceOf(address(this));
        eq(vaultBalanceAfter, vaultBalanceBefore + expectedAssets, "vaultBalanceAfter must increase by expectedAssets amount");
    }

    function vault_redeem(uint256 shares, address receiver, address owner) updateBeforeAfter public {
        uint256 totalSupplyBefore = vault.totalSupply();
        
        vault.redeem(shares, receiver, owner);

        uint256 totalSupplyAfter = vault.totalSupply();
        eq(totalSupplyAfter, totalSupplyBefore - shares, "totalSupplyAfter must decrease by shares amount");
    }

    function vault_withdraw(uint256 assets, address receiver, address owner) updateBeforeAfter public {
        vault.withdraw(assets, receiver, owner);
    }
}