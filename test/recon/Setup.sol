// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Managers
import {ActorManager} from "recon/ActorManager.sol";
import {AssetManager} from "recon/AssetManager.sol";

import {ERC4626Tester} from "src/ERC4626Tester.sol";
import {MockERC20Tester} from "src/MockERC20Tester.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager {
    MockERC20Tester internal underlyingAsset;
    ERC4626Tester internal vault;

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
        address _underlyingAsset = _newAsset(18);

        // Deploy a new vault
        vault = new ERC4626Tester(IERC20(_underlyingAsset));
    }
}
