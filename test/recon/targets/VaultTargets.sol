
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "test/recon/BeforeAfter.sol";
import {Properties} from "test/recon/Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract VaultTargets is Properties, BaseTargetFunctions {

    function vault_approve(address spender, uint256 value) public asActor {
        __before();
        vault.approve(spender, value);
        __after();

        eq(_before.pricePerShare, _after.pricePerShare, "pricePerShare should not change");
    }
    
    function vault_transfer(address to, uint256 value) public asActor {
        __before();
        vault.transfer(to, value);
        __after();

        eq(_before.pricePerShare, _after.pricePerShare, "pricePerShare should not change");
    }

    function vault_deposit(uint256 assets, address receiver) public updateGhosts asActor {        
        vault.deposit(assets, receiver);
    }

    function vault_mint(uint256 shares, address receiver) public updateGhosts asActor {
        uint256 expectedAssets = vault.previewMint(shares);
        uint256 vaultBalanceBefore = underlyingAsset.balanceOf(address(this));
        
        vault.mint(shares, receiver);
        
        uint256 vaultBalanceAfter = underlyingAsset.balanceOf(address(this));
        eq(vaultBalanceAfter, vaultBalanceBefore + expectedAssets, "vaultBalanceAfter must increase by expectedAssets amount");
    }

    function vault_redeem(uint256 shares, address receiver, address owner) public asActor {
        __before();
        vault.redeem(shares, receiver, owner);
        __after();

        eq(_after.vaultTotalShares, _before.vaultTotalShares - shares, "vault totalSupply should decrease by shares amount");
    }

    function vault_withdraw(uint256 assets, address receiver, address owner) public updateGhosts asActor {
        vault.withdraw(assets, receiver, owner);
    }
}