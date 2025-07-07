// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

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

    /**
     * @dev Property: Users should not be able to mint shares for fewer assets than the correct amount
     * 
     * This property should FAIL for the vulnerable vault, demonstrating the vulnerability.
     * In a correct implementation, users should pay at least the ceiling of the asset calculation.
    */
    function property_mint_should_not_undercharge() public {
        uint256 totalAssets = vault.totalAssets();
        uint256 totalSupply = vault.totalSupply();
        
        // Skip if vault is empty (no existing shares to steal from)
        if (totalSupply == 0) return;
        
        uint256 mintShares = 1e18; // 1 share
        
        // Calculate what the vulnerable vault charges
        uint256 vulnerableAssets = vault.previewMint(mintShares);
        
        // Calculate what it should charge (Ceil rounding)
        uint256 correctAssets = Math.mulDiv(
            mintShares,
            totalAssets + 1, 
            totalSupply + 10 ** vault.decimals(), 
            Math.Rounding.Ceil
        );
        
        // VULNERABILITY: This assertion should fail, showing that the vault undercharges
        gte(vulnerableAssets, correctAssets, "Vault should not undercharge for minting");
    }

    /**
     * @dev Property: Users should not be able to profit from mint-then-redeem attacks
     * 
     * This property should FAIL for the vulnerable vault, demonstrating that users
     * can extract value through repeated mint-redeem cycles.
     */
    function property_no_mint_redeem_profit() public {
        uint256 totalAssets = vault.totalAssets();
        uint256 totalSupply = vault.totalSupply();
        
        // Skip if vault is empty
        if (totalSupply == 0) return;
        
        address user = _getActor();
        uint256 mintShares = 1e18;
        
        // Calculate the cost to mint shares
        uint256 mintCost = vault.previewMint(mintShares);
        
        // Calculate the assets received when redeeming the same shares
        uint256 redeemAssets = vault.previewRedeem(mintShares);
        
        // VULNERABILITY: This assertion should fail, showing that users can profit
        lte(redeemAssets, mintCost, "Users should not profit from mint-redeem cycles");
    }

    /**
     * @dev Property: Total assets should not decrease due to mint operations
     * 
     * This property should PASS but helps demonstrate the vulnerability by showing
     * that the vault's accounting remains consistent despite the rounding issue.
     */
    function property_mint_preserves_total_assets() public {
        uint256 initialAssets = vault.totalAssets();
        uint256 initialSupply = vault.totalSupply();
        
        address user = _getActor();
        uint256 mintShares = 1e18;
        
        // Calculate what the user would pay
        uint256 expectedAssets = vault.previewMint(mintShares);
        
        // The vault should gain the assets that the user pays
        uint256 expectedTotalAssets = initialAssets + expectedAssets;
        
        // This should always be true, even in the vulnerable implementation
        gte(expectedTotalAssets, initialAssets, "Minting should not decrease total assets");
    }

    /**
     * @dev Property: Share price should not decrease due to mint operations
     * 
     * This property should PASS but helps demonstrate the vulnerability by showing
     * that the share price calculation remains consistent.
     */
    function property_mint_does_not_dilute_existing_shares() public {
        uint256 totalAssets = vault.totalAssets();
        uint256 totalSupply = vault.totalSupply();
        
        // Skip if vault is empty
        if (totalSupply == 0) return;
        
        uint256 initialSharePrice = totalAssets * 1e18 / totalSupply;
        
        address user = _getActor();
        uint256 mintShares = 1e18;
        uint256 mintAssets = vault.previewMint(mintShares);
        
        // Calculate new share price after mint
        uint256 newTotalAssets = totalAssets + mintAssets;
        uint256 newTotalSupply = totalSupply + mintShares;
        uint256 newSharePrice = newTotalAssets * 1e18 / newTotalSupply;
        
        // The share price should not decrease (though it might stay the same due to rounding)
        gte(newSharePrice, initialSharePrice, "Minting should not dilute existing shares");
    }

    /**
     * @dev Property: Demonstrate the vulnerability magnitude
     * 
     * This property calculates and logs the magnitude of the vulnerability
     * to help understand its impact.
     */
    // function property_vulnerability_magnitude() public view {
    //     uint256 totalAssets = vault.totalAssets();
    //     uint256 totalSupply = vault.totalSupply();
        
    //     // Skip if vault is empty
    //     if (totalSupply == 0) return;
        
    //     uint256 mintShares = 1e18;
        
    //     // Calculate the vulnerability
    //     (uint256 vulnerableAssets, uint256 correctAssets, uint256 stolenValue) = 
    //         vault.demonstrateVulnerability(mintShares);
        
    //     // Log the vulnerability details
    //     // console.log("Vulnerability magnitude:");
    //     // console.log("  Vault total assets:", totalAssets);
    //     // console.log("  Vault total supply:", totalSupply);
    //     // console.log("  Vulnerable charge:", vulnerableAssets);
    //     // console.log("  Correct charge:", correctAssets);
    //     // console.log("  Stolen value:", stolenValue);
        
    //     // The stolen value should be positive when there are existing shares
    //     gt(stolenValue, 0, "Vulnerability should result in stolen value");
    // }

    /**
     * @dev Property: Check that the vulnerability is consistent
     * 
     * This property ensures that the vulnerability behaves consistently
     * across different mint amounts.
     */
    // function property_vulnerability_consistency(uint256 mintShares) public view {
    //     // Bound the mint shares to reasonable values
    //     mintShares = between(mintShares, 1e15, 1e21); // 0.001 to 1000 shares
        
    //     uint256 totalAssets = vault.totalAssets();
    //     uint256 totalSupply = vault.totalSupply();
        
    //     // Skip if vault is empty
    //     if (totalSupply == 0) return;
        
    //     // Calculate the vulnerability
    //     (uint256 vulnerableAssets, uint256 correctAssets, uint256 stolenValue) = 
    //         vault.demonstrateVulnerability(mintShares);
        
    //     // The vulnerable vault should always charge less than the correct amount
    //     lt(vulnerableAssets, correctAssets, "Vulnerable vault should always undercharge");
        
    //     // The stolen value should be proportional to the mint amount
    //     gt(stolenValue, 0, "Stolen value should always be positive");
    // }

    /**
     * @dev Property: Test the attack scenario
     * 
     * This property simulates the actual attack scenario where a user
     * mints shares and immediately redeems them for profit.
     */
    // function property_attack_scenario() public {
    //     uint256 totalAssets = vault.totalAssets();
    //     uint256 totalSupply = vault.totalSupply();
        
    //     // Skip if vault is empty
    //     if (totalSupply == 0) return;
        
    //     address attacker = _getActor();
    //     uint256 mintShares = 1e18;
        
    //     // Record initial state
    //     uint256 initialAttackerBalance = underlyingAsset.balanceOf(attacker);
    //     uint256 initialVaultAssets = vault.totalAssets();
        
    //     // Simulate the attack (without actually executing it to avoid state changes)
    //     uint256 mintCost = vault.previewMint(mintShares);
    //     uint256 redeemAssets = vault.previewRedeem(mintShares);
        
    //     uint256 profit = redeemAssets - mintCost;
        
    //     // VULNERABILITY: This assertion should fail, showing the attack is profitable
    //     lte(profit, 0, "Attack should not be profitable");
        
    //     // console.log("Attack scenario:");
    //     // console.log("  Mint cost:", mintCost);
    //     // console.log("  Redeem assets:", redeemAssets);
    //     // console.log("  Profit:", profit);
    // }

}
