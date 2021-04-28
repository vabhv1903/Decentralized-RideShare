pragma solidity >=0.4.24;

import '../core/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Ride is Ownable {
  using SafeMath for uint256;

/********************** Public Varables ***********************/
  // Contract owner
  address payable owner;
  // Placeholder for driver address
  address payable driverID;

  // Define a public mapping 'items' that maps the address to a ride.
  mapping (address => RideItem) items;
  mapping (address => address) driverRides;
  mapping (address => Txblocks) itemsHistory;

  // Set default ride state
  State constant defaultState = State.None;

  // Enum contains ride states
  enum State
  {
    None,
    PassengerRequestRide,
    DriverAcceptsRide,
    PassengerConfirmsPickUp,
    DriverConfirmsDropOff,
    Canceled
  }

  // Struct contains all ride components
  struct RideItem {
    address ownerID;                       // Metamask-Ethereum address of the cBlockPassengerPaymentSentent owner as the product moves through 4 stages
    address payable driverID;              // Metamask-Ethereum address of the driver
    address payable passengerID;           // Metamask-Ethereum address of the rider
    address rideID;                        // Ride ID
    string  passengerName;                 // Passenger name
    string  passengerVehicleRequestType;   // Passenger vehicleRequestType
    string  passengerPickUpAddress;        // Passenger pickup address
    string  passengerDropOffAddress;       // passenger dropoff address
    string  driverVehicleDiscription;      // drivers vehicleDiscription
    uint256 rideDate;                      // Ride Date: In Epoche
    uint    ridePrice;                     // Ride Price
    State   rideState;                     // Ride State as represented in the enum above
  }

// Block number stuct
  struct Txblocks {
    uint BlockPassengerPaymentSent; // block ether from passenger to contact
    uint BlockDriverPaymentSent; // block ether from passenger to driver
  }

/********************** Events ***********************/
event PassengerRequestRide(address rideID);
event DriverAcceptsRide(address rideID);
event PassengerConfirmsPickUp(address rideID);
event DriverConfirmsDropOff(address rideID);
event CanceledRide(address rideID);

/********************** Modifiers ***********************/
  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner,"Only contract owner is allowed to call this method");
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address,"Address is not verified to call this method");
    _;
  }

  modifier verifyCallerIsRelatedToContract(address _rideID) {
    require(msg.sender == items[_rideID].driverID || msg.sender == items[_rideID].passengerID,"Address is not verfied to call this method");
    _;
  }

  // Modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) {
    require(msg.value >= _price,"Paid amount is insufficient to cover the price");
    _;
  }

  // Modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _price, address payable addressToFund) {
    uint  amountToReturn = msg.value - _price;
    addressToFund.transfer(amountToReturn);
    _;
  }

  // Modifier that checks if a passenger can request a new ride
  modifier hasExistingRide(address _rideID) {
    require(items[_rideID].rideState != State.DriverAcceptsRide,"Ride needs to be canceled before making a new ride.");
    require(items[_rideID].rideState != State.PassengerConfirmsPickUp,"Ride needs to be canceled before making a new ride.");
    _;
  }


  modifier isRideCanceled(address _rideID) {
    require(items[_rideID].rideState != State.Canceled,"Ride has been cancel by passenger");
    _;
  }

  modifier isRideComplete(address _rideID){
    require(items[_rideID].rideState != State.DriverConfirmsDropOff,"This method ride is complete by driver");
    _;
  }

  // RideItem State Modifiers
  modifier passengerRequestedRide(address _rideID) {
    require(items[ _rideID].rideState == State.PassengerRequestRide);
    _;
  }

  modifier driverAcceptedRide(address _rideID) {
    require(items[ _rideID].rideState == State.DriverAcceptsRide);
    _;
  }

  modifier passengerConfirmedPickUp(address _rideID) {
    require(items[ _rideID].rideState == State.PassengerConfirmsPickUp);
    _;
  }

  modifier driverConfirmedDropOff(address _rideID) {
    require(items[ _rideID].rideState == State.DriverConfirmsDropOff);
    _;
  }


  /********************** Constructor & Kill Function ***********************/
  constructor() public {
    // Set contract owner
    owner = msg.sender;
  }

  // Kill function to black Hole the contract
  function kill() public {
    if (msg.sender == owner) {
      address payable ownerAddressPayable = _make_payable(owner);
      selfdestruct(ownerAddressPayable);
    }
  }

    // allows you to convert an address into a payable address
  function _make_payable(address x) internal pure returns (address payable) {
    return address(uint160(x));
  }



  /********************** Ride Functions ***********************/
  // Allows for the cancelation of a ride
  function cancelRide(address _rideID) public payable
  verifyCallerIsRelatedToContract(_rideID)
  isRideComplete(_rideID) // check if ride is complete
  isRideCanceled(_rideID) // check if ride has already been canceled
  {
    // 25% cancelation fee goes to driver
    if (items[ _rideID].rideState == State.PassengerConfirmsPickUp) {
      items[ _rideID].rideState = State.Canceled;

      uint256 driverAmount = items[_rideID].ridePrice.mul(2500).div(10000);
      uint256 remainder = items[_rideID].ridePrice - driverAmount;

      items[ _rideID].passengerID.transfer(remainder);
      items[ _rideID].driverID.transfer(driverAmount);
      driverRides[items[ _rideID].driverID] =  address(0x0);
      emit CanceledRide(_rideID);
    }else if (items[_rideID].rideState == State.DriverAcceptsRide && msg.sender == items[_rideID].driverID){
      items[_rideID].rideState = State.PassengerRequestRide;
      driverRides[msg.sender] =  address(0x0);
      items[_rideID].driverVehicleDiscription = "";
      items[_rideID].driverID = address(0x0);

      emit PassengerRequestRide(_rideID);
    }else{

      items[ _rideID].rideState = State.Canceled;
      items[ _rideID].passengerID.transfer(address(this).balance);
      driverRides[items[ _rideID].driverID] =  address(0x0);
      emit CanceledRide(_rideID);
    }
  }


  /*
   1st step in ride share
   Allows passenger to request a ride with there perfered settings
   Passenger ether will transfer into contract address until
  */
  function passengerRequestRide(
                                    string memory _passengerName,
                                    string memory _passengerPickUpAddress,
                                    string memory _passengerDropOffAddress,
                                    string memory _passengerVehicleRequestType,
                                    uint _ridePrice
                                ) public payable


    hasExistingRide(msg.sender)        // Check if passenger has a existing ride
    paidEnough(_ridePrice)             // Check if passenger has paid enough for ride
    checkValue(_ridePrice, msg.sender) // Check if passenger has over paid

    {

    string memory _driverName;                                            // Empty drivers Name
    string memory _driverVehicleDiscription;                              // Empty drivers vehicleDiscription

    RideItem memory newRide;                                           // Create a new struct RideItem in memory
    newRide.driverID = driverID;                                       // Ethereum address of the driver emtpy for now
    newRide.rideID = msg.sender;                                       // Ethereum address of the passenger is rideId
    newRide.passengerID = _make_payable(msg.sender);                   // Payable ethereum address of the passenger
    newRide.passengerName = _passengerName;                            // Passenger Name
    newRide.passengerPickUpAddress = _passengerPickUpAddress;          // Passenger pickup address
    newRide.passengerDropOffAddress = _passengerDropOffAddress;        // Passenger dropoff address
    newRide.passengerVehicleRequestType = _passengerVehicleRequestType;// Passenger request for specific vehicle
    newRide.driverVehicleDiscription = _driverVehicleDiscription;      // Drive vehicle discription
    newRide.ridePrice = _ridePrice;                                    // Ride Price
    newRide.rideDate = now;                                            // Current date & time of ride
    newRide.rideState = State.PassengerRequestRide;                    // Ride State as represented in the enum above
    items[msg.sender] = newRide;                                       // Add newRide to items struct by upc

    uint placeholder;                                                     // Block number place holder
    Txblocks memory txBlock;                                              // create new txBlock struct
    txBlock.BlockPassengerPaymentSent = block.number;                     // add block number
    txBlock.BlockDriverPaymentSent = placeholder;                         // assign placeholder values

    itemsHistory[msg.sender] = txBlock;                                   // add txBlock to itemsHistory mapping by upc

    // Emit the appropriate event
    emit PassengerRequestRide(msg.sender);
  }

/*
2nd step in ride share
Allows a driver to accept a ride
*/
  function driverAcceptsRide(
                                address _rideID,
                                string memory _driverVehicleDiscription
                            ) public
    passengerRequestedRide(_rideID)
    isRideCanceled(_rideID)
    {
      driverRides[msg.sender] = _rideID;
      items[_rideID].rideState = State.DriverAcceptsRide;
      items[_rideID].driverID = _make_payable(msg.sender);
      items[_rideID].driverVehicleDiscription = _driverVehicleDiscription;

      emit DriverAcceptsRide( _rideID);
  }

  /*
  3rd step in ride share
  Allows the passenger to confirm the pickup
  NOTE
  - passenger is allowed to cancel the ride up to this point, Ether return back to the passenger
  */
  function passengerConfirmsPickUp(address _rideID) public
    driverAcceptedRide(_rideID) // check items state is for passengerConfirmsPickUp
    verifyCaller(items[ _rideID].passengerID)
    isRideCanceled(_rideID)
    {
      items[ _rideID].rideState = State.PassengerConfirmsPickUp; // update state
      emit PassengerConfirmsPickUp( _rideID);
    }


  /*
  4th step in ride share
  Allows drive to confirm passenger dropoff
  Driver will be paid from contract address
  */
  function driverConfirmsDropOff(address _rideID) public
    passengerConfirmedPickUp(_rideID)
    verifyCaller(items[_rideID].driverID) // check if same drive as pickup
    isRideCanceled(_rideID)
    {
      // Add block number to history mapping
      itemsHistory[ _rideID].BlockPassengerPaymentSent = block.number;
      // Update state
      items[ _rideID].rideState = State.DriverConfirmsDropOff;
      // Pay driver from contract
      items[ _rideID].driverID.transfer(items[_rideID].ridePrice);
      // Map drivers address to no rideID
      driverRides[msg.sender] = address(0x0);
      // Emit related event
      emit DriverConfirmsDropOff(_rideID);
  }


  // allows driver address to get current rideID
  function fetchDriverBuffer() public view returns (address rideID)
  {
    address rideid = driverRides[msg.sender];
    return (rideid);
  }


  // Define a function 'fetchRideItemBufferOne' that fetches the data
  /*
  address passengerID;
  string  passengerName;                 // Passenger name
  string  passengerVehicleRequestType;   // Passenger vehicleRequestType
  string  passengerPickUpAddress;        // Passenger pickup address
  string  passengerDropOffAddress;       // passenger dropoff address
  */
  function fetchRideItemBufferOne(address _rideID) public view returns
    //verifyCaller(items[_rideID].passengerID); // only allows the passenger to request there info
    (
      address passengerID,
      string memory passengerName,
      string memory passengerVehicleRequestType,
      string memory passengerPickUpAddress,
      string memory passengerDropOffAddress
    )
    {
    // Assign values to the 8 parameters
    RideItem memory item = items[ _rideID];
    return
    (
      item.passengerID,
      item.passengerName,
      item.passengerVehicleRequestType,
      item.passengerPickUpAddress,
      item.passengerDropOffAddress
    );
  }

  /*
  address driverID;                 // Metamask-Ethereum address of the driver
  string  driverVehicleDiscription; // drivers vehicleDiscription
  */
  function fetchRideItemBufferTwo(address _rideID) public view returns
    (
      address driverID,
      string memory driverVehicleDiscription
    )
    {
    // Assign values to the 8 parameters
    RideItem memory item = items[ _rideID];
    return
    (
      item.driverID,
      item.driverVehicleDiscription
    );
  }

  /*
  string  rideNotes;                // Ride Notes
  uint256 rideDate;                 // Ride Date
  uint    ridePrice;                // Ride Price
  State   rideState;                // Ride State as represented in the enum above
  */
  function fetchRideItemBufferThree(address _rideID) public view returns
    (
      uint256 rideDate,
      uint ridePrice,
      State rideState
    )
    {
      RideItem memory item = items[ _rideID];
      return
      (
        item.rideDate,
        item.ridePrice,
        item.rideState
      );
    }

  // Define a function 'fetchRideItemHistory' that fetaches the data
  function fetchRideItemHistory(address _rideID) public view returns
    (
      uint BlockPassengerToContract,
      uint BlockContractToDriver
    )
    {
      // Assign value to the parameters
      Txblocks memory txblock = itemsHistory[_rideID];
      return
      (
        txblock.BlockPassengerPaymentSent,
        txblock.BlockDriverPaymentSent
      );
    }

  }
