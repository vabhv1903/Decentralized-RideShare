pragma solidity >=0.4.24;

//import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import '../core/Ownable.sol';
import '../core/RideToken.sol';

contract Escrow is Ownable {
    enum PaymentStatus { Pending, Completed, Refunded }

    ERC20Basic token;
    ERC20Basic driverToken;

    event PaymentCreation(address indexed orderId, address indexed driver, uint value);
    event PaymentCompletion(address indexed orderId, address indexed driver, uint value, PaymentStatus status);

    struct Payment {
        address driver;
        uint value;
        PaymentStatus status;
        bool refundApproved;
    }

    mapping(address => Payment) public payments;
    //ERC20 public currency;
    address user;
    //address payable driver;

   constructor(address _user) public {
        //currency = _currency
        user = _user;
        //webshop = Webshop(msg.sender);
    }

    function createPayment(address _orderId,address _driver, uint _value) public payable{
        //token = RideToken(msg.sender);
        //token.mint();
        //token.approve(_driver,_value);
        //token.deposit.value(msg.value)();
        //payments[_orderId] = Payment(_driver, _value, PaymentStatus.Pending, false);
        //emit PaymentCreation(_orderId, _driver, _value);
    }

    function release(address _orderId) external {
        //driverToken = RideToken(msg.sender);

        //token.transferFrom(user,payments[_orderId].driver,payments[_orderId].value);
        //token.burn(payments[_orderId].value);
        //driverToken.withdraw(payments[_orderId].value);
        //completePayment(_orderId, collectionAddress, PaymentStatus.Completed);
        //token.transferFrom
    }

    //function refund(address _orderId) external {
    //    completePayment(_orderId, msg.sender, PaymentStatus.Refunded);
    //}

  //  function approveRefund(address _orderId) external {
//        require(msg.sender == collectionAddress);
  //      Payment storage payment = payments[_orderId];
  //      payment.refundApproved = true;
    //}
/*
    function completePayment(address _orderId, address _receiver, PaymentStatus _status) private {
        Payment storage payment = payments[_orderId];
        require(payment.customer == msg.sender);
        require(payment.status == PaymentStatus.Pending);
        if (_status == PaymentStatus.Refunded) {
            require(payment.refundApproved);
        }
        token.transfer(_receiver, payment.value);
        //webshop.changeOrderStatus(_orderId, Webshop.OrderStatus.Completed);
        payment.status = _status;
        emit PaymentCompletion(_orderId, payment.driver, payment.value, _status);
    }
    */
}
