// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
import {FundMe} from '../src/FundMe.sol';
import {HelperConfig} from './HelperConfig.s.sol';
import {Test, console} from 'forge-std/Test.sol';

contract DeployFundMe is Script {
    function run() external returns(FundMe) {

        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        console.log(block.chainid);
        console.log(helperConfig.activeNetworkConfig());
        // mock
        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
