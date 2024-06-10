// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from 'forge-std/Test.sol';

import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from '../script/DeployFundMe.s.sol';

contract FundMeTest is Test {
    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant GAS_PRICE = 1 wei; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether; // just a value to make sure we are sending enough!
    FundMe public fundMe;

    address USER = makeAddr('user'); // cheatcode for user address

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe df = new DeployFundMe();
        fundMe = df.run();
        vm.deal(USER, 100e18); // cheatcode balance
    }
    function testMinimunUsdIsFive() public view {
        console.log('testMinimunUsdIsFive');
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // function testOwnerIsDeployer() public view {
    //     console.log('testOwnerIsDeployer');
    //     assertEq(fundMe.getOwner(), address(this));
    // }

    function testGetVersion() public view {
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFaildWithoutEngouthEth() public {
        vm.expectRevert(); // 测试正常revert
        fundMe.fund{value: 0}();
    }

    function testFundFaildWithEngouthEth() public {
        vm.prank(USER); // cheatcode
        fundMe.fund{value: 10e18}(); // 10 eth

        // uint256 amount = fundMe.getAddressToAmountFunded(address(this));
        uint256 amount = fundMe.getAddressToAmountFunded(USER);

        assertEq(amount, 10e18);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(address(3)); // Not the owner
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance; // 开始时合约的余额
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 开始时owner的余额

        // vm.txGasPrice(GAS_PRICE); // 设置交易的gas价格
        // uint256 gasStart = gasleft();// gasleft() 函数返回当前交易还剩余的gas数量
        // // Act
        vm.startPrank(fundMe.getOwner()); // cheatcode
        fundMe.withdraw(); // withdraw all the funds
        vm.stopPrank(); // stop cheatcode

        // uint256 gasEnd = gasleft(); // gasleft() 函数返回当前交易还剩余的gas数量
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // gasUsed = (开始时的gas数量 - 结束时的gas数量) * gas价格

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance; // 结束时合约的余额
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // 结束时owner的余额
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE); // cheatcode
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fundMe.getOwner().balance - startingOwnerBalance
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE); // cheatcode
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fundMe.getOwner().balance - startingOwnerBalance
        );
    }
}
