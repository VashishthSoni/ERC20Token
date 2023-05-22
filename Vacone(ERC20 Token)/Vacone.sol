//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interface/IERC20.sol";

contract Vacone is IERC20 {
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Vacone";
    string public symbol = "VAC";
    uint256 public decimals = 18;

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
    }

    modifier checkAmount(uint256 _amount) {
        require(_amount > 0, "Amount must be Non-zero");
        _;
    }

    modifier checkAddress(address _recipient) {
        require(_recipient != address(0) && _recipient != address(1), "Invalid Address");
        _;
    }

    function transfer(address recipient, uint256 amount)
        external
        checkAmount(amount)
        checkAddress(recipient)
        returns (bool)
    {
        require(balanceOf[msg.sender] >= amount, "Insufficient Balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        checkAmount(amount)
        checkAddress(spender)
        returns (bool)
    {
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        checkAmount(amount)
        checkAddress(recipient)
        returns (bool)
    {
        require(balanceOf[sender] >= amount, "Insufficient Funds");
        require(allowance[sender][msg.sender] >= amount, "Approved funds are less");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) external checkAmount(amount) {
        // require()
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient funds");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
