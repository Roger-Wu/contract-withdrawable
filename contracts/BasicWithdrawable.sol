pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/// @title BasicWithdrawable
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A cheap and not so secure implementation of a withdrawable contract.
/// @dev Inherit this contract to enable withdrawal from a contract.
contract BasicWithdrawable {
  using SafeMath for uint;

  /// @dev user balances in wei
  mapping (address => uint) private balances;

  /// public getters

  function balanceOf(address _user) public view returns(uint _balance) {
    return balances[_user];
  }

  /// public functions

  function() public payable {
    deposit();
  }

  function deposit() public payable {
    _increaseBalance(msg.sender, msg.value);
  }

  function transfer(address _to, uint _amount) public {
    require(_amount <= balances[msg.sender]);

    _decreaseBalance(msg.sender, _amount);
    _increaseBalance(_to, _amount);
  }

  function withdrawAll() public {
    /// @dev Only to avoid wasting gas.
    require(balances[msg.sender] > 0);

    /// @dev To avoid re-entrancy attack, update the balance before transfer.
    uint _amount = balances[msg.sender];
    _decreaseBalance(msg.sender, _amount);

    msg.sender.transfer(_amount);
  }

  function withdraw(uint _amount) public {
    require(_amount <= balances[msg.sender]);

    _decreaseBalance(msg.sender, _amount);

    msg.sender.transfer(_amount);
  }

  /// internal functions

  /// @dev This function should be called when the derived contract gets paid and would like to update the balance of a user.
  function depositTo(address _user, uint _amount) internal {
    require(_user != address(0));
    _increaseBalance(_user, _amount);
  }

  /// private functions

  function _increaseBalance(address _user, uint _amount) private {
    balances[_user] = balances[_user].add(_amount);
  }

  function _decreaseBalance(address _user, uint _amount) private {
    balances[_user] = balances[_user].sub(_amount);
  }
}