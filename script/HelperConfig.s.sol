// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.s.sol';
contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory MainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return MainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            //如果已赋值直接返回，避免创建新的
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator m3 = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory AnvilConfig = NetworkConfig({
            priceFeed: address(m3)
        });
        return AnvilConfig;
    }
}
