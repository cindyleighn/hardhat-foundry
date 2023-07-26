// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/console.sol";
import "contracts/Lock.sol";


// these tests are a rewrite of the hardhat tests in Lock.ts
// foundry tests must be prefixed with test to be picked up during test run
contract LockFoundryTest is Test {
    Lock public lock;

    // event to be tested
    event Withdrawal(uint amount, uint when);

    // required to receive funds from the contract (withdraw())
    receive() external payable {}

    // used to execute tests at present day
    modifier startAtPresentDay() {
        vm.warp(PRESENT_DAY);
        _;
    }

    // used to execute tests at a valid withdrawal date
    modifier startAtValidWithdrawalDay() {
        vm.warp(unlockTime + 1 days);
        _;
    }

    // variables
    uint256 ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    uint256 PRESENT_DAY = 1680616584;

    uint256 lockedAmount;
    uint256 unlockTime;

    address public owner = address(this);
    address public otherAccount = address(0x5E11E1); // random address

    // executed before each test
    function setUp() public startAtPresentDay {
        unlockTime = block.timestamp + ONE_YEAR_IN_SECS;
        lockedAmount = 1 ether;
        lock = new Lock{value: lockedAmount}(unlockTime);
    }

    // unit tests
    function testCorrectUnlocktTimeSet() public {
        console.log("Deployment should set the right unlockTime");
        assertEq(lock.unlockTime(), unlockTime);
    }

    function testCorrectOwnerSet() public {
        console.log("Deployment should set the right owner");
        assertEq(lock.owner(), owner);
    }

    function testReceiveAndStoreFundsToLock() public {
        console.log("Deployment should receive and store the funds to lock");
        assertEq(address(lock).balance, lockedAmount);
    }

    function testRevertIfUnlockTimeNotInFuture() public startAtPresentDay {
        console.log("Deployment should fail if the unlockTime is not in the future");
        vm.expectRevert("Unlock time should be in the future");
        new Lock{value: lockedAmount}(PRESENT_DAY);
    }

    function testRevertIfCalledTooSoon() public startAtPresentDay {
        console.log("Withdrawal should revert with the right error if called too soon");
        vm.expectRevert("You can't withdraw yet");
        lock.withdraw();
    }

    function testRevertIfCalledFromAnotherAccount() public startAtValidWithdrawalDay {
        console.log("Withdrawal revert with the right error if called from another account");
        vm.startPrank(otherAccount);
        vm.expectRevert("You aren't the owner");
        lock.withdraw();
        vm.stopPrank();
    }

    function testValidWithDrawal() public startAtValidWithdrawalDay {
        console.log("Withdrawal shouldn't fail if the unlockTime has arrived and the owner calls it");
        lock.withdraw();
    }

    function testEventOnWithdraw() public startAtValidWithdrawalDay {
        console.log("Withdrawal should emit an event");
        vm.expectEmit();
        emit Withdrawal(lockedAmount, block.timestamp);
        lock.withdraw();
    }

    function testTransferToOwner() public startAtValidWithdrawalDay {
        console.log("Withdrawal should transfer the funds to the owner");
        uint256 oldBalance = address(owner).balance;
        lock.withdraw();
        uint256 newBalance = address(owner).balance;
        assertEq(oldBalance + lockedAmount, newBalance);
        assertEq(address(lock).balance, 0);
    }
}