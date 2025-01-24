// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 vaultTotalShares;
        uint256 ghostTotalShares;
        uint256 pricePerShare;
    }

    Vars internal _before;
    Vars internal _after;

    modifier updateBeforeAfter() {
        __before();
        _;
        __after();
    }

    function __before() internal {
        _before.vaultTotalShares = vault.totalSupply();
        _before.ghostTotalShares = vault.balanceOf(address(this));
        _before.pricePerShare = vault.previewMint(10**vault.decimals());
    }

    function __after() internal {
        _after.vaultTotalShares = vault.totalSupply();
        _after.ghostTotalShares = vault.balanceOf(address(this));
        _after.pricePerShare = vault.previewMint(10**vault.decimals());
    }
}
