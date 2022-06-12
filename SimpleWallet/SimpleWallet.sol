//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

    import "./Allowance.sol";

    contract SharedWallet is Allowance {

    event MoneySent(address indexed _beneficiary, uint amount);
    event MoneyRecived(address indexed _from, uint amount);
    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Contract doswn't own enought money");
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }

    function renounceOwnership() public view override onlyOwner {
        revert("can't renounceOwnership here");
    }

    receive() external payable {
        emit MoneyRecived(msg.sender, msg.value);
    } 
}