// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/src/Test.sol";
import "../src/Vacone.sol";
import "forge-std/src/console.sol";

contract VaconeTest is Test {
    Vacone public vac;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        vm.prank(address(1));
        vac = new Vacone(1000);
    }

    function testMint() public {
        vm.startPrank(address(1));

        console.log("Before Mint", vac.totalSupply());
        vac.mint(10);

        console.log("After Mint", vac.totalSupply());
        console.log("Address:", msg.sender, "Balance", vac.balanceOf(address(1)));

        vm.stopPrank();
    }

    function testTransfer() public {
        vm.startPrank(address(1));

        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));

        vac.transfer(address(2), 10);
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));
        console.log("Address:", address(2), "Balance", vac.balanceOf(address(2)));

        vac.transfer(address(3), 100);
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));
        console.log("Address:", address(3), "Balance", vac.balanceOf(address(3)));

        vm.expectRevert(bytes("Amount must be Non-zero"));
        vac.transfer(address(2), 0);
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));

        vm.stopPrank();
    }

    function testApprove() public {
        vm.startPrank(address(1));
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));

        vac.approve(address(2), 100);

        vm.stopPrank();
        vm.prank(address(2));
        vac.transferFrom(address(1), address(3), 50);
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));
        console.log("Address:", address(3), "Balance", vac.balanceOf(address(3)));
    }

    function testBurn() public {
        vm.startPrank(address(1));
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));

        console.log("Before Burn", vac.totalSupply());
        vac.burn(500);
        console.log("After Burn", vac.totalSupply());
        console.log("Address:", address(1), "Balance", vac.balanceOf(address(1)));

        vm.stopPrank();
    }

    function testTransferAgain() public {
        vm.startPrank(address(1));

        vm.expectRevert(bytes("Invalid Address"));
        vac.transfer(address(0), 10);

        vm.stopPrank();
        vm.expectRevert(bytes("Insufficient Balance"));
        vac.transfer(address(13), 100);
    }

    function testApproveAgain() public {
        vm.startPrank(address(1));

        vm.expectRevert(bytes("Insufficient funds"));
        vac.approve(address(3), 10000);

        vm.expectRevert(bytes("Amount must be Non-zero"));
        vac.approve(address(3), 0);

        vm.stopPrank();
    }

    function testBurnAgain() public {
        vm.expectRevert(bytes("Insufficient funds"));
        vac.burn(100);
    }

    function testTransferFromAgain() public {
        console.log(address(this));
        vm.expectRevert(bytes("Approved funds are less"));
        vac.transferFrom(address(1), address(3), 100);

        vm.expectRevert(bytes("Insufficient Funds"));
        vac.transferFrom(address(6), address(3), 100);
    }

    function testEvents() public {
        vm.startPrank(address(1));

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(1), address(3), 100);
        vac.transfer(address(3), 100);

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), address(1), 100);
        vac.mint(100);

        vm.expectEmit(true, true, false, true);
        emit Approval(address(1), address(3), 100);
        vac.approve(address(3), 100);

        vac.transfer(address(this), 100);

        vm.stopPrank();

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), address(0), 100);
        vac.burn(100);
    }
}
