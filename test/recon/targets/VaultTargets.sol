
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "test/recon/BeforeAfter.sol";
import {Properties} from "test/recon/Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract VaultTargets is Properties, BaseTargetFunctions {

    function vault_approve(address spender, uint256 value) public asActor {
        vault.approve(spender, value);
    }
    
    /// @dev We clamp the possible recipients for the property_total_supply_solvency check
    function vault_transfer(uint256 toEntropy, uint256 value) public asActor {
        address to = _getRandomActor(toEntropy);
        vault.transfer(to, value);
    }

    function vault_deposit(uint256 assets) public updateGhosts asActor {        
        vault.deposit(assets, _getActor());
    }

    function vault_mint(uint256 shares) public updateGhosts {
        uint256 expectedAssets = vault.previewMint(shares);
        uint256 vaultBalanceBefore = underlyingAsset.balanceOf(address(vault));
        
        // explicit prank as actor here because external calls are made above which would consume it with the modifier
        vm.prank(_getActor());
        vault.mint(shares, _getActor());
        
        uint256 vaultBalanceAfter = underlyingAsset.balanceOf(address(vault));
        eq(vaultBalanceAfter, vaultBalanceBefore + expectedAssets, "vaultBalanceAfter must increase by expectedAssets amount");
    }

    function vault_redeem(uint256 shares) public updateGhosts asActor {
        vault.redeem(shares, _getActor(), _getActor());
    }

    function vault_withdraw(uint256 assets) public updateGhosts asActor {
        vault.withdraw(assets, _getActor(), _getActor());
    }

    /// === Helpers === ///
    function _getRandomActor(uint256 entropy) internal view returns (address) {
        address[] memory actors = _getActors();
        uint256 randomIndex = entropy % actors.length;
        return actors[randomIndex];
    }
}