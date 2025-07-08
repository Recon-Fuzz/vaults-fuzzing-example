// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MockERC20 } from "@recon/MockERC20.sol";

// Managers
import {ActorManager} from "recon/ActorManager.sol";
import {AssetManager} from "recon/AssetManager.sol";

import {ERC4626Vault} from "src/ERC4626Vault.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager {
    MockERC20 internal underlyingAsset;
    ERC4626Vault internal vault;

    uint256 internal initialSupply = 1e26;

    /// === MODIFIERS === ///
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }

    function setup() internal virtual override {
        // Add an additional actor
        _addActor(address(0x1234));

        // Deploy a new asset
        underlyingAsset = MockERC20(_newAsset(18));

        // Deploy a new vault
        vault = new ERC4626Vault(underlyingAsset);

        // Mints the deployed asset to all actors and sets max allowances for the vault
        address[] memory approvalArray = new address[](1);
        approvalArray[0] = address(vault);
        _finalizeAssetDeployment(_getActors(), approvalArray, type(uint88).max);
    }
}
