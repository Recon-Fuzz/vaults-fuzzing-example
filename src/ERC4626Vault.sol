// SPDX-License-Identifier: MIT
// Heavily inspired by https://github.com/liquity/V2-gov/blob/9632de9a988522775336d9b60cdf2542efc600db/test/mocks/MaliciousInitiative.sol
pragma solidity ^0.8.0;

import { MockERC20 } from "@recon/MockERC20.sol";
import { console2 } from "forge-std/console2.sol";

contract ERC4626Vault is MockERC20 {
    MockERC20 public immutable asset;

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    constructor(MockERC20 _asset) MockERC20("MockERC4626Tester", "MCT", 18) {
        asset = _asset;
    }

    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 shares = previewDeposit(assets);
        _deposit(msg.sender, receiver, assets, shares);
        return shares;
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 assets = previewMint(shares);
        _deposit(msg.sender, receiver, assets, shares);
        return assets;
    }

    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256) {
        uint256 shares = previewWithdraw(assets);
        _withdraw(msg.sender, receiver, owner, assets, shares);
        return shares;
    }

    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 assets = previewRedeem(shares);
        console2.log("assets from previewRedeem %e", assets);
        _withdraw(msg.sender, receiver, owner, assets, shares);
        return assets;
    }

    function totalAssets() public view virtual returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply;
        if (supply == 0) return assets;
        
        // VULNERABILITY: Precision Loss Inflation Attack
        // This creates a subtle inflation vulnerability through precision loss manipulation
        // The attack works by exploiting division-before-multiplication in specific scenarios
        
        uint256 totalAssets_ = totalAssets();
        
        // Step 1: Calculate share percentage first (division before multiplication)
        uint256 sharePercentage = assets * 1e18 / totalAssets_;  // Get percentage with 18 decimals
        
        // Step 2: Apply percentage to total supply
        uint256 shares = sharePercentage * supply / 1e18;
        
        // The vulnerability: When totalAssets_ >> assets, sharePercentage rounds down to 0
        // This allows attackers to:
        // 1. Deposit large amount to inflate totalAssets
        // 2. Make small deposits from other accounts that get 0 shares due to rounding
        // 3. Withdraw their initial deposit plus the "donated" assets from failed deposits
        
        return shares;
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? assets : assets * supply / totalAssets();
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply;
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        asset.transferFrom(caller, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(caller, receiver, assets, shares);
    }

    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
        virtual
    {
        if (caller != owner) {
            allowance[owner][caller] -= shares;
        }
        _burn(owner, shares);

        asset.transfer(receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }
}