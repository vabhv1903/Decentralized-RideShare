pragma solidity >=0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
import '../accessControl/User.sol';

// Define a contract 'DriverRole' to manage this role - add, remove, check
contract DriverRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event DriverAdded(address indexed account);
  event DriverRemoved(address indexed account);

  // Define a struct 'Drivers' by inheriting from 'Roles' library, struct Role
  Roles.Role private Drivers;

  // In the constructor make the address that deploys this contract the 1st Driver
  constructor() public {
    _addDriver(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyDriver() {
    require(isDriver(msg.sender));
    _;
  }

  // Define a function 'isDriver' to check this role
  function isDriver(address account) public view returns (bool) {
    return Drivers.has(account);
  }

  // Define a function 'addDriver' that adds this role
  function addDriver(address account) public onlyDriver
  {
    _addDriver(account);
  }

  // Define a function 'renounceDriver' to renounce this role
  function renounceDriver() public {
    _removeDriver(msg.sender);
  }

  // Define an internal function '_addDriver' to add this role, called by 'addDriver'
  function _addDriver(address account) internal {
    Drivers.add(account);
    emit DriverAdded(account);
  }

  // Define an internal function '_removeDriver' to remove this role, called by 'removeDriver'
  function _removeDriver(address account) internal {
    Drivers.remove(account);
    emit DriverRemoved(account);
  }
}
