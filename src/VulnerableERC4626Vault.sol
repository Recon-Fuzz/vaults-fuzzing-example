// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @dev Vulnerable ERC4626 Vault that demonstrates a mint vulnerability
 * 
 * VULNERABILITY: Incorrect rounding in previewMint and mint functions
 * 
 * The vulnerability lies in the _convertToAssets function which uses Floor rounding
 * instead of Ceil rounding when converting shares to assets. This allows users to
 * mint shares for fewer assets than they should pay, effectively stealing value
 * from other vault participants.
 * 
 * In a proper ERC4626 implementation:
 * - previewMint should use Ceil rounding to ensure users pay enough assets
 * - mint should use the same Ceil rounding to match previewMint
 * 
 * This implementation incorrectly uses Floor rounding, allowing users to pay less
 * than the fair value for their shares.
 */
contract VulnerableERC4626Vault is ERC4626 {
    using Math for uint256;

    constructor(IERC20 _asset) ERC4626(_asset) ERC20("VulnerableVault", "VVLT") {}

    /**
     * @dev VULNERABLE: Override _convertToAssets to use Floor rounding instead of Ceil
     * 
     * This is the core vulnerability. When users mint shares, they should pay
     * the ceiling of the asset calculation to ensure they pay enough. Using
     * Floor rounding allows them to pay less than they should.
     */
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual override returns (uint256) {
        // VULNERABILITY: Always use Floor rounding instead of respecting the rounding parameter
        // This means users can mint shares for fewer assets than they should pay
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), Math.Rounding.Floor);
    }

    /**
     * @dev VULNERABLE: Override previewMint to use Floor rounding
     * 
     * This should use Ceil rounding to ensure users pay enough assets for their shares.
     * Using Floor rounding allows users to pay less than the fair value.
     */
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        // VULNERABILITY: Uses Floor rounding instead of Ceil
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    /**
     * @dev VULNERABLE: Override mint to use Floor rounding
     * 
     * This should use Ceil rounding to match previewMint and ensure users pay enough.
     */
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        // VULNERABILITY: Use Floor rounding instead of Ceil
        uint256 assets = _convertToAssets(shares, Math.Rounding.Floor);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /**
     * @dev Helper function to demonstrate the vulnerability
     * 
     * This function shows how much a user would pay for shares using the vulnerable
     * implementation vs. what they should pay in a correct implementation.
     */
    function demonstrateVulnerability(uint256 shares) external view returns (
        uint256 vulnerableAssets,
        uint256 correctAssets,
        uint256 stolenValue
    ) {
        // What the vulnerable vault charges (Floor rounding)
        vulnerableAssets = previewMint(shares);
        
        // What it should charge (Ceil rounding)
        correctAssets = shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), Math.Rounding.Ceil);
        
        // The stolen value
        stolenValue = correctAssets - vulnerableAssets;
    }

    /**
     * @dev Attack scenario: User mints shares and immediately redeems them for profit
     * 
     * 1. User mints shares using the vulnerable Floor rounding (pays less)
     * 2. User immediately redeems shares using correct Ceil rounding (gets more)
     * 3. User profits from the rounding difference
     */
    function attackScenario(uint256 shares) external returns (uint256 profit) {
        uint256 initialBalance = IERC20(asset()).balanceOf(msg.sender);
        
        // Step 1: Mint shares (pays less due to Floor rounding)
        uint256 assetsPaid = mint(shares, msg.sender);
        
        // Step 2: Immediately redeem shares (gets more due to Ceil rounding in redeem)
        uint256 assetsReceived = redeem(shares, msg.sender, msg.sender);
        
        // Step 3: Calculate profit
        profit = assetsReceived - assetsPaid;
        
        uint256 finalBalance = IERC20(asset()).balanceOf(msg.sender);
        require(finalBalance > initialBalance, "Attack failed - no profit made");
    }
} 