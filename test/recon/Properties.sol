// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {Asserts} from "@chimera/Asserts.sol";

import {BeforeAfter, OpType} from "./BeforeAfter.sol";

abstract contract Properties is BeforeAfter, Asserts {
    function property_user_cannot_change_price_per_share() public {
        if(currentOpType == OpType.ADD || currentOpType == OpType.REMOVE) {
            eq(_before.pricePerShare, _after.pricePerShare, "price per share should not change with user operations");
        }
    }

}
