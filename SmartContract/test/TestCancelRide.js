// This script is designed to test the solidity smart contract - SuppyChain.sol -- and the various functions within
// Declare a variable and assign the compiled smart contract artifact

/*
var RideContract = artifacts.require('Ride')

contract('Ride', function(accounts) {
    // Declare few constants and assign a few sample accounts generated by ganache-cli
    var ownerID = accounts[0]
    const userID = accounts[1]
    const userName = "John Doe"
    const userPickUpAddress = "6491 S Spotswood St, Littleton, CO 80120"
    const userDropOffAddress = "Winter Park, CO 80482"
    const userVehicleRequestType = "Car"
    const ridePrice = web3.utils.toWei('0.5', "ether")


    var itemState = 0
    var rideID = null;
    const driverID = accounts[2]
    const driverName = "Ricky BOB"
    const driverVehicleDiscription = "Red Toyota Rav4 "

    console.log("<----------------ACCOUNTS----------------> ")
    console.log("Contract Owner: accounts[0] ", accounts[0])
    console.log("User: accounts[1] ", accounts[1])
    console.log("Driver: accounts[2] ", accounts[2])
    console.log("<-------TESTING CONTRACT FUNCTIONS------->")


    it("Testing smart contract function userRequestRide", async() => {
        const contract = await RideContract.deployed();
        // No longer needed
        //await contract.addUser(userID);
        //await contract.addDriver(driverID);

        // Declare and Initialize a variable for event
        var eventEmitted = false;
        var balance = web3.utils.toWei('1', "ether");

        //var result = await supplyChain.userRequestRide.estimateGas(userName, userPickUpAddress, userDropOffAddress, userVehicleRequestType, ridePrice, {from:userID,value:balance})
        var result = await contract.userRequestRide(userName, userPickUpAddress, userDropOffAddress, userVehicleRequestType, ridePrice, {from:userID,value:balance})

        // Retrieve the just now saved item from blockchain by calling function fetchItem()
        // check for last past emitted events
        await contract.getPastEvents('UserRequestRide', {
            fromBlock: 0,
            toBlock: 'latest'
        }, (error, events) => { console.log(events,error); })
        .then((events) => {
            rideID = events[0].returnValues.rideID;
            eventEmitted = true;
            assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
        });
    });


    it("Testing smart contract function driverAcceptsRide", async() => {
        const contract = await RideContract.deployed()

        // Declare and Initialize a variable for event
        var eventEmitted = false;
        await contract.driverAcceptsRide(rideID,driverVehicleDiscription,{from: driverID});

        // Watch the emitted event Processed()
        await contract.getPastEvents('DriverAcceptsRide', {
            fromBlock: 0,
            toBlock: 'latest'
        }, (error, events) => { console.log(events,error); })
        .then((events) => {
            eventEmitted = true;
            assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
            //console.log(events) // same results as the optional callback above
        });
    });


    it("Testing Cancel Ride" , async() => {
      const contract = await RideContract.deployed()

      await contract.cancelRide(rideID,{from: userID});
      const resultBufferThree = await contract.fetchItemBufferThree(rideID);

      await contract.getPastEvents('CanceledRide', {
            fromBlock: 0,
            toBlock: 'latest'
        }, (error, events) => { console.log(events,error); })
        .then((events) => {
            eventEmitted = true;
            assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
      });
    });

    it("Testing Cancel Ride" , async() => {
      const contract = await RideContract.deployed()

      await contract.cancelRide(rideID,{from: userID});
      const resultBufferThree = await contract.fetchItemBufferThree(rideID);

      await contract.getPastEvents('CanceledRide', {
            fromBlock: 0,
            toBlock: 'latest'
        }, (error, events) => { console.log(events,error); })
        .then((events) => {
            eventEmitted = true;
            assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
      });
    });

    it("Testing smart contract function userConfirmsPickUp", async() => {
        const contract = await RideContract.deployed()
        await contract.userConfirmsPickUp(rideID,{from: userID});

        await contract.getPastEvents('UserConfirmsPickUp', {
            fromBlock: 0,
            toBlock: 'latest'
        }, (error, events) => { console.log(events,error); })
        .then((events) => {
            eventEmitted = true;
            assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
        });
      });

      it("Testing smart contract function driverConfirmsDropOff", async() => {
          const contract = await RideContract.deployed()
          await contract.driverConfirmsDropOff(rideID,{from: driverID});
          await contract.getPastEvents('DriverConfirmsDropOff', {
              fromBlock: 0,
              toBlock: 'latest'
          }, (error, events) => { console.log(events,error); })
          .then((events) => {
              eventEmitted = true;
              assert.equal(eventEmitted, true, 'Error: Invalid item SKU');
        });
    });

    it("Testing smart contract fetchItemThree", async() => {
      const contract = await RideContract.deployed()
      //const resultFetchItemHistory = await supplyChain.fetchitemHistory(rideID);
      const resultBufferThree = await contract.fetchItemBufferThree(rideID);

    });

    it("Testing smart contract fetchItemTwo", async() => {
      const contract = await RideContract.deployed()
      //const resultFetchItemHistory = await supplyChain.fetchitemHistory(rideID);
      const resultBufferTwo = await contract.fetchItemBufferTwo(rideID);
    });

    it("Testing smart contract fetchItemHistory", async() => {
      const contract = await RideContract.deployed()
      //const resultFetchItemHistory = await supplyChain.fetchitemHistory(rideID);
      const resultBufferTwo = await contract.fetchItemBufferTwo(rideID);
    });
});
*/

//"abi":[{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"rideID","type":"address"}],"name":"DriverAcceptsRide","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"DriverAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"rideID","type":"address"}],"name":"DriverConfirmsDropOff","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"DriverRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"oldOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"TransferOwnership","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"UserAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"rideID","type":"address"}],"name":"UserConfirmsPickUp","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"account","type":"address"}],"name":"UserRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"rideID","type":"address"}],"name":"UserRequestRide","type":"event"},{"constant":false,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"addDriver","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"addUser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"_rideID","type":"address"},{"internalType":"string","name":"_driverName","type":"string"},{"internalType":"string","name":"_driverVehicleDiscription","type":"string"}],"name":"driverAcceptsRide","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"driverConfirmsDropOff","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"fetchItemBufferOne","outputs":[{"internalType":"address","name":"userID","type":"address"},{"internalType":"string","name":"userName","type":"string"},{"internalType":"string","name":"userVehicleRequestType","type":"string"},{"internalType":"string","name":"userPickUpAddress","type":"string"},{"internalType":"string","name":"userDropOffAddress","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"fetchItemBufferThree","outputs":[{"internalType":"string","name":"rideNotes","type":"string"},{"internalType":"uint256","name":"rideDate","type":"uint256"},{"internalType":"uint256","name":"ridePrice","type":"uint256"},{"internalType":"enum Ride.State","name":"rideState","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"fetchItemBufferTwo","outputs":[{"internalType":"address","name":"driverID","type":"address"},{"internalType":"string","name":"driverName","type":"string"},{"internalType":"string","name":"driverVehicleDiscription","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"fetchitemHistory","outputs":[{"internalType":"uint256","name":"BlockUserToContract","type":"uint256"},{"internalType":"uint256","name":"BlockContractToDriver","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"isDriver","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"isOwner","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"isUser","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"ownerLookup","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"renounceDriver","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"renounceOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"renounceUser","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"_rideID","type":"address"}],"name":"userConfirmsPickUp","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"_userName","type":"string"},{"internalType":"string","name":"_userPickUpAddress","type":"string"},{"internalType":"string","name":"_userDropOffAddress","type":"string"},{"internalType":"string","name":"_userVehicleRequestType","type":"string"},{"internalType":"uint256","name":"_ridePrice","type":"uint256"}],"name":"userRequestRide","outputs":[],"payable":true,"stateMutability":"payable","type":"function"}],"devdoc":{"methods":{}},"userdoc":{"methods":{"isOwner()":{"notice":"Check if the calling address is the owner of the contract"},"ownerLookup()":{"notice":"Look up the address of the owner"},"renounceOwnership()":{"notice":"Define a function to renounce ownerhip"},"transferOwnership(address)":{"notice":"Define a public function to transfer ownership"}}}