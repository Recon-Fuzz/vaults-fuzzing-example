
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter, OpType} from "test/recon/BeforeAfter.sol";
import {Properties} from "test/recon/Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract VaultTargets is BaseTargetFunctions, Properties {

    function vault_approve(address spender, uint256 value) public updateGhosts asActor {
        vault.approve(spender, value);
    }
    
    function vault_transfer(address to, uint256 value) public updateGhosts asActor {
        vault.transfer(to, value);
    }

    function vault_deposit(uint256 assets) public updateGhostsWithOpType(OpType.ADD) asActor {        
        vault.deposit(assets, _getActor());
    }

    function vault_mint(uint256 shares) public updateGhostsWithOpType(OpType.ADD) asActor {
        vault.mint(shares, _getActor());
    }

    function vault_redeem(uint256 shares) public updateGhostsWithOpType(OpType.REMOVE) asActor {
        vault.redeem(shares, _getActor(), _getActor());
    }

    function vault_withdraw(uint256 assets) public updateGhostsWithOpType(OpType.REMOVE) asActor {
        vault.withdraw(assets, _getActor(), _getActor());
    }
}