// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Interface for ERC20 token
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Axelar's dependencies
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

// We will be using uniswap V3 for swapping assets (call on dest chain)
/* TODO: Call on src chain to swap to an asset that is supported on the dest chain */

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract CrosschainSwap is AxelarExecutable {
    // WMATIC and WETH on Polygon
    address public wethPolygon = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public wmaticPolygon = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    // Define gas service
    IAxelarGasService public immutable gasService;

    //  Uniswap Swap Router
    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    // gateway and gas service are passed to the constructor
    // We can reference to them from the docs: https://docs.axelar.dev/resources/contract-addresses/testnet
    constructor(
        address _gateway,
        address _gasService
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
    }

    function crosschainSwap(
        string memory _destChain, // Polygon
        string memory _destCa, // address(this)
        string memory _symbol, // WETH
        uint256 _amount //
    ) external payable {
        require(msg.value > 0, "Gas fee required");

        uint24 poolFee = 3000;

        address tokenAddress = gateway.tokenAddresses(_symbol); // Get token address from the source chain

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        IERC20(tokenAddress).approve(address(swapRouter), _amount);

        // Setup message for Uniswap to send to Axelar Gateway
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: wethPolygon,
                tokenOut: wmaticPolygon,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp + 1000,
                amountIn: _amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Encode the swap params --> So that Axelar can understand
        bytes memory encodedSwapParams = abi.encode(params);

        // pay multichain gas cost
        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destChain,
            _destCa,
            encodedSwapParams,
            _symbol,
            _amount,
            msg.sender
        );

        // trigger crosschain transaction
        gateway.callContractWithToken(
            _destChain,
            _destCa,
            encodedSwapParams,
            _symbol,
            _amount
        );
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata _payload,
        string calldata,
        uint256 _amount
    ) internal override {
        ISwapRouter.ExactInputSingleParams memory decodedSwapParams = abi
            .decode(_payload, (ISwapRouter.ExactInputSingleParams)); // decode the received params

        IERC20(wethPolygon).approve(address(swapRouter), _amount);

        swapRouter.exactInputSingle(decodedSwapParams); // execute the swap
    }
}
