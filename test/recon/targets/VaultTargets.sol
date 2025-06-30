
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "test/recon/BeforeAfter.sol";
import {Properties} from "test/recon/Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract VaultTargets is Properties, BaseTargetFunctions {

    function vault_approve(address spender, uint256 value) public updateGhosts asActor {
        vault.approve(spender, value);
    }
    
    /// @dev We clamp the possible recipients for the property_total_supply_solvency check
    function vault_transfer(uint256 toEntropy, uint256 value) public updateGhosts asActor {
        address to = _getRandomActor(toEntropy);
        vault.transfer(to, value);
    }

    /// @dev Property: The `deposit` function should never revert for a depositor that has sufficient balance and approvals
    function vault_deposit(uint256 assets) public updateGhosts asActor {  
        try vault.deposit(assets, _getActor()) {
        } catch (bytes memory reason) {
            bool expectedError = checkError(reason, "InsufficientBalance(address,uint256,uint256)") || checkError(reason, "InsufficientAllowance(address,address,uint256,uint256)");
            // precondition: we only care about reverts for things other than insufficient balance or allowance
            if (!expectedError) {
                revert("deposit should not revert");
            }
        }
    }

    /// @dev Property: vaultBalance must increase by deposited assets amount
    function vault_mint(uint256 shares) public updateGhosts asActor {
        vault.mint(shares, _getActor());
    }

    function vault_redeem(uint256 shares) public updateGhostsWithOpType(OpType.REMOVE) asActor {
        vault.redeem(shares, _getActor(), _getActor());
    }

    function vault_withdraw(uint256 assets) public updateGhostsWithOpType(OpType.REMOVE) asActor {
        vault.withdraw(assets, _getActor(), _getActor());
    }

    /// === Helpers === ///
    function _getRandomActor(uint256 entropy) internal view returns (address) {
        address[] memory actors = _getActors();
        uint256 randomIndex = entropy % actors.length;
        return actors[randomIndex];
    }
}