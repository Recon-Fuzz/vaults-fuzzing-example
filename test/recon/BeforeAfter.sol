// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

enum OpType {
    DEFAULT,
    ADD,
    REMOVE
}

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 vaultTotalShares;
        uint256 ghostTotalShares;
        uint256 pricePerShare;
    }

    Vars internal _before;
    Vars internal _after;
    OpType internal currentOpType;

    modifier updateGhosts() {
        currentOpType = OpType.DEFAULT;
        __before();
        _;
        __after();
    }

    modifier updateGhostsWithOpType(OpType opType) {
        currentOpType = opType;
        __before();
        _;
        __after();
    }   

    function __before() internal {
        _before.pricePerShare = vault.convertToShares(10**vault.decimals());
    }

    function __after() internal {
        _after.pricePerShare = vault.convertToShares(10**vault.decimals());
    }
}
