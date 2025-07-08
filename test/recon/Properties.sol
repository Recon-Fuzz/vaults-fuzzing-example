// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Asserts} from "@chimera/Asserts.sol";
import {console2} from "forge-std/console2.sol";

import {BeforeAfter, OpType} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {
    function property_user_cannot_change_price_per_share() public {
        if(currentOpType == OpType.ADD || currentOpType == OpType.REMOVE) {
            console2.log("price per share difference", _before.pricePerShare - _after.pricePerShare);
            eq(_before.pricePerShare, _after.pricePerShare, "price per share should not change with user operations");
        }
    }

    /// === Optimization Properties ===
    function optimize_user_increases_price_per_share() public returns (int256) {
        if(currentOpType == OpType.ADD || currentOpType == OpType.REMOVE) {
            if(_before.pricePerShare < _after.pricePerShare) {
                maxPriceDifferenceIncrease = int256(_after.pricePerShare) - int256(_before.pricePerShare);
                return maxPriceDifferenceIncrease;
            }
        }
    }

    function optimize_user_decreases_price_per_share() public returns (int256) {
        if(currentOpType == OpType.ADD || currentOpType == OpType.REMOVE) {
            if(_before.pricePerShare > _after.pricePerShare) {
                maxPriceDifferenceDecrease = int256(_before.pricePerShare) - int256(_after.pricePerShare);
                return maxPriceDifferenceDecrease;
            }
        }
    }

}
