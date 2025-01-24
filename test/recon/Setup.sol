// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC4626Tester} from "src/ERC4626Tester.sol";
import {MockERC20Tester} from "src/MockERC20Tester.sol";

abstract contract Setup is BaseSetup {
    MockERC20Tester internal underlyingAsset;
    ERC4626Tester internal vault;

    uint256 internal initialSupply = 1e26;

    function setup() internal virtual override {
        underlyingAsset = new MockERC20Tester(address(this), initialSupply, "MockERC20", "MRC20", 18);
        vault = new ERC4626Tester(IERC20(address(underlyingAsset)));
    }
}
