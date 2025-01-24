// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IERC20 {
    function approve(address guy, uint256 wad) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    function allowance(address, address) external view returns (uint256);
}

interface IUniswapV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes memory data
    ) external;
}

contract CapTest is Test {
    address capHuff;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address UNIV2_WETH_USDT_PAIR = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;

    /// @dev Setup the testing environment.
    function setUp() public {
        capHuff = HuffDeployer.deploy("Cap");
    }

    /// @dev Ensure that you can set and get the value.
    function testUniswapCall(uint256 value) public {
        WETH.call{value: 10e18}("");
        IERC20(WETH).transfer(capHuff, 10e18);

        bytes memory callbackPayload = abi.encodePacked(
            uint96(1e18),
            address(UNIV2_WETH_USDT_PAIR),
            address(WETH)
        );

        // WETH - token0, USDT - token1

        // Send WETH, receive USDT
        bytes memory payload = abi.encodePacked(
            hex"f61d5205",
            address(UNIV2_WETH_USDT_PAIR),
            bool(false),
            uint88(1_000e6),
            uint16(callbackPayload.length),
            callbackPayload
        );

        capHuff.call(payload);
    }
}
