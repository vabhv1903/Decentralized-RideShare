// migrating the appropriate contracts
//var UserRole = artifacts.require("./UserRole.sol");
//var DriverRole = artifacts.require("./DriverRole.sol");
var Ride = artifacts.require("./Ride.sol");

module.exports = function(deployer) {
  //deployer.deploy(UserRole);
  //deployer.deploy(DriverRole);
  deployer.deploy(Ride);
};
