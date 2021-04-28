//
//  RideViewController.swift
//  Decent-Ride
//
//  Created by Mitchell Tucker on 2/12/21.
//

import Foundation
import UIKit
import Web3swift
import PromiseKit
import BigInt
import MapKit


// Global vars
var wallet:Wallet?
var contract:RideContract?

var web3:web3?
var role:Role = .passenger
var rideState:RideStates = .noActiveRide

var password:String? // Unsafe

var network:Network = .ganache

var rideID:EthereumAddress?

let primaryColor = UIColor(red: CGFloat(47.0/255.0), green: CGFloat(215.0/255.0), blue: CGFloat(248/255.0), alpha: 1.0)

class RideViewController: UIViewController, Web3SocketDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    //MARK: Variables
    // Better to keep subscribtion events sepreate from contract calls
    var socketProvider: InfuraWebsocketProvider? = nil // Infura WebSocket Provider
    var wssSocket: InfuraWebsocketProvider? = nil // wss SocketProvider
    
    // GanacheSocket
    var ganacheSocket:WebsocketProvider? = nil
    
    var balanceBarButton:UIBarButtonItem?
    var walletNameBarButton:UIBarButtonItem?
    
    // Location manager for current location
    let locationManager = CLLocationManager()
    
    // Toggles inteceping new rides writen onto the chain
    private var driverListenForRides = false
    
    // Map overlays and annotations
    private var pickUpAnnotation:MKPointAnnotation? = nil
    private var dropOffAnnotation:MKPointAnnotation? = nil
    private var driveRoute:MKRoute? = nil
    
    // Outlets
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var buildRideStackView: UIStackView!
    
    @IBOutlet weak var driverTextStackView: UIStackView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dropOffAddressField: UITextField!
    @IBOutlet weak var pickUpAddressField: UITextField!
    @IBOutlet weak var vehicleSegment: UISegmentedControl!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rideDetailsStackView: UIStackView!
    @IBOutlet weak var reconnectSocket: UIButton!
    @IBOutlet weak var driverDetailsStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listingIndicator: UIActivityIndicatorView? = nil
    @IBOutlet weak var nextStep: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var driverVehicleTextField: UITextField!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var ridePrice: UILabel!
    @IBOutlet weak var rideDate: UILabel!
    @IBOutlet weak var pickUpAddress: UILabel!
    @IBOutlet weak var dropOffAddress: UILabel!
    @IBOutlet weak var driverVehicle: UILabel!
    @IBOutlet weak var driverEther: UILabel!
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextStep.layer.cornerRadius = 25.0
        cancel.layer.cornerRadius = 15.0
        
        nextStep!.layer.cornerRadius = 10.0
        cancel!.layer.cornerRadius = 10.0
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        // TODO: add actions to Navi bar buttons
        // Add toggle between ETH and Dollars
        balanceBarButton = UIBarButtonItem(
            title: "0.0000 ETH",
            style: .plain,
            target: navigationController,
            action: nil)
        
        balanceBarButton!.tintColor = primaryColor
        
        // Add toggle between wallet name and wallet address
        walletNameBarButton = UIBarButtonItem(
            title: "\(wallet!.name)",
            style: .plain,
            target: self,
            action: #selector(seeWalletAddress(sender:))
        )
        
        walletNameBarButton!.tintColor = primaryColor
        walletNameBarButton!.tag = 0 // jump between tags
        
        // Navigation Setup
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = balanceBarButton!
        navigationItem.rightBarButtonItem = walletNameBarButton!
        
        // Setup Contract with wallet address
        contract = RideContract(wallet: wallet!)
        
        // Create and start listing for new events
        if network == .ganache {
            ganacheSocket = createGanacheSocket()
        }else{
            wssSocket = createSocket()
        }
        
        
        
        // Methods below could be used to reconnect if disconnected
        // NOTE: Ping/Pong the wss socket would be a better pattern to follow "heart beat"
        //wssSocket!.socket.onDisconnect = { dis in
        //    self.reconnectSocket.isHidden = false
        //    self.nextStep.isHidden = true
        //    self.cancel.isHidden = true
        //}
        
        //wssSocket!.socket.onConnect = {
        //    self.reconnectSocket.isHidden = true
        //    self.nextStep.isHidden = false
        //    self.cancel.isHidden = false
        //}
        
        // Get account balance
        updateAccountBalance()
        
        // Get current ride state for wallet
        if role == .passenger {
            rideID = EthereumAddress(wallet!.address)
            getRideState(address: rideID!)
        }else{
            getDriverState()
        }
    }
    
    //MARK: IBActions
    
    // Currently hidden but could be used for reconnecting if socket disconnects
    @IBAction func reconnectSocketAction(_ sender: Any) {
        wssSocket!.socket.connect()
    }
    // Toggles between wallet address & name
    @objc func seeWalletAddress(sender: UIBarButtonItem) {
        if walletNameBarButton!.tag == 0{
            walletNameBarButton!.title = wallet!.address
            walletNameBarButton!.tag = 1
        }else{
            walletNameBarButton!.title = wallet!.name
            walletNameBarButton!.tag = 0
        }
    }
    
    // MARK: NextStepButton
    // Action is responsable for writing or call the next step within the ride state
    @IBAction func nextStepButton(_ sender: Any) {
        
        switch rideState {
        // Three states conclude in completeing or ending a ride
        case .cancelRide, .noActiveRide,.driverConfirmsDropOff:
            
            if role == .passenger {
                let type = vehicleSegment.titleForSegment(at: vehicleSegment.selectedSegmentIndex)
                // TODO calculate ride cost based on ride factors
                // For demo purposes use a fixed Ether ride cost
                let ridePrice = "0.03"
                let amount = Web3.Utils.parseToBigUInt(ridePrice, units: .eth)! // convert ride price to correct ETH amount
                
                // Ride parameters
                let pickUpAddress = pickUpAddressField.text
                let dropOffAddress = dropOffAddressField.text
                let userName = nameField.text
                let parameters = [userName,pickUpAddress,dropOffAddress,type,amount] as [AnyObject]
                
                // Write to contract method with ride parameters
                // End Ride -> User Request Ride
                let _ = writeContractMethod(method: .passengerRequestRide , amount: amount, parameters: parameters)
                // Show user we are waiting for event
                self.listingIndicator!.startAnimating()
                self.buildRideStackView.isHidden = true
                self.nextStep!.isSelected = true
                self.nextStep!.setTitle("Ride Requested", for: .selected)
                
            }else{
                
                self.cancel.setTitle("Stop", for: .normal)
                // Show cancel button when listening for ride
                self.cancel.isHidden = false
                self.driverTextStackView.isHidden = true
                self.nextStep!.isSelected = true
                self.nextStep!.setTitle("Listening", for: .selected)
                self.nextStep!.titleLabel?.textAlignment = .right
                self.listingIndicator!.startAnimating()
                
                // Driver is now listening for userRequestedRide events
                self.driverListenForRides = true
            }
            
        case .passengerRequestRide:
            if role == .passenger {
                // Waiting for driver to accept ride
            }else{
                // Driver is accepting ride
                let driverRide = driverVehicleTextField.text
                let parameters = [rideID!.address,driverRide] as [AnyObject]
                
                // Using callContractMethod no Ether is being sent
                // State Change: User Request Ride -> Driver Accepts Ride
                let _ = callContractMethod(method: .driverAcceptsRide, parameters: parameters)
                
                // Set button to selected
                self.nextStep.setTitle("Accepting Ride", for: .selected)
                self.nextStep.isSelected = true
                self.listingIndicator!.startAnimating()
            }
            
        case .driverAcceptsRide:
            if role == .passenger {
                // User confirms pick Up
                let parameters = [wallet!.address] as [AnyObject]
                
                // State Change: Driver Accepts Ride -> User Confirms PickUp
                let _ = callContractMethod(method: .passengerConfirmsPickUp, parameters: parameters)
                
                self.nextStep.setTitle("Confirming PickUp", for: .selected)
                self.nextStep.isSelected = true
                self.listingIndicator!.startAnimating()
            }else{
                // driver waiting for user to accept ride
            }
            
        case .passengerConfirmsPickUp:
            if role == .passenger {
                // waiting for driver to accept dropOff
            }else{
                
                let parameters = [rideID!.address] as [AnyObject]
                // State Change: User Confirms PickUp -> Driver Confirms DropOff
                let _ = callContractMethod(method: .driverConfirmsDropOff, parameters: parameters)
                
                self.nextStep.setTitle("Confirming DropOff", for: .selected)
                self.nextStep.isSelected = true
                self.listingIndicator!.startAnimating()
            }
        }
    }
    
    // MARK: cancelRideAction
    @IBAction func cancelRideAction(_ sender: Any) {
        // Allows driver to skip a UserRequestRide event
        if cancel!.titleLabel!.text == "Skip" {
            rideDetailsStackView.isHidden = true
            
            rideID = nil // clear rideID
            changeViewState(state: .noActiveRide)
            clearMap()
        }
        // Allows driver to stop listing for UserRequestRide events
        else if cancel!.titleLabel!.text == "Stop" {
            driverListenForRides = false
            changeViewState(state: .noActiveRide)
            clearMap()
        }
        else{
            let cancelParameters = [rideID] as [AnyObject]
            firstly {
                // Call cancel ride contract method
                callContractMethod(method: .cancelRide, parameters: cancelParameters)
            }.done { response in
                // Notify user that ride is being canceled
                self.nextStep.setTitle("Canceling Ride", for: .selected)
                self.nextStep.isSelected = true
                self.cancel.isHidden = true
            }
        }
    }
    
    
    // MARK: changeViewState
    // Updates views based on given ride state
    func changeViewState(state:RideStates) {
        
        // Update rideState
        rideState = state
        
        // Default ride state
        self.nextStep.isSelected = false
        self.cancel.setTitle("Cancel", for: .normal)
        self.cancel.isHidden = false
        self.nextStep.isHidden = false
        self.driverDetailsStackView.isHidden = true
        // Change views based on ride state
        switch state {
        case .cancelRide, .noActiveRide, .driverConfirmsDropOff:
            self.clearMap()
            if role == .passenger {
                
                self.listingIndicator!.stopAnimating()
                
                self.buildRideStackView.isHidden = false
                self.rideDetailsStackView.isHidden = true
                
                // Update buttons for the next step in ride
                self.nextStep.setTitle("Request a Ride!", for: .normal)
                self.nextStep.isSelected = false
                self.cancel.isHidden = true
                
            }else{
                
                if driverListenForRides {
                    self.listingIndicator!.startAnimating()
                    
                    self.driverTextStackView.isHidden = true
                    self.rideDetailsStackView.isHidden = true
                    
                    self.nextStep.isSelected = true
                    self.nextStep.setTitle("Listening", for: .selected)
                    self.cancel.isHidden = false
                    self.cancel.setTitle("Stop", for: .normal)
                    
                    
                }else {
                    self.listingIndicator!.stopAnimating()
                    
                    self.driverTextStackView.isHidden = false
                    self.nextStep.isSelected = false
                    self.nextStep.setTitle("Listen for Ride!", for: .normal)
                    self.rideDetailsStackView.isHidden = true
                    
                    self.cancel.isHidden = true
                    
                }
            }
            
        case .passengerRequestRide:
            
            if role == .passenger {
                self.nextStep!.setTitle("Waiting for driver to accept ride", for: .selected)
                self.nextStep!.isSelected = true
                self.listingIndicator!.startAnimating()
                self.buildRideStackView.isHidden = true
                self.rideDetailsStackView.isHidden = false
                
            }else{
                self.listingIndicator!.stopAnimating()
                self.rideDetailsStackView.isHidden = false
                self.nextStep!.setTitle("Accept Ride", for: .normal)
                self.cancel!.setTitle("Skip", for: .normal)
            }
            
        case .driverAcceptsRide:
            // Get updated ride info from contract
            self.getRideDetails(rideID)
            self.getRideDriver(rideID)
            
            self.driverDetailsStackView.isHidden = false
            self.rideDetailsStackView.isHidden = false
            if role == .passenger {
                self.listingIndicator!.stopAnimating()
                self.nextStep!.setTitle("Confirm PickUp", for: .normal)
            }else{
                self.nextStep!.setTitle("Waiting For passenger to Confirm PickUp", for: .selected)
                self.nextStep.isSelected = true
                self.listingIndicator!.startAnimating()
            }
            
        case .passengerConfirmsPickUp:
            self.driverDetailsStackView.isHidden = false
            self.rideDetailsStackView.isHidden = false
            if role == .passenger {
                self.nextStep!.setTitle("Waiting for driver to Confirm Drop Off", for: .selected)
                self.nextStep.isSelected = true
                self.listingIndicator!.startAnimating()
            }else{
                self.listingIndicator!.stopAnimating()
                self.nextStep!.setTitle("Confirm Drop Off", for: .normal)
            }
        }
    }
    
    
    // MARK: WebSocket Delegate Methods
    
    // Currently subscribied to all events (Topics)
    // TODO: Only subscrible to events (Topics) that are relevant to the current ride state

    /****NOTES**
            Works for both ganache and infura rinkbey test net. Both are a little different with rensponse
     */
    func received(message: Any) {
        print("message\(message)")
        var result: SubscribtionResult?
        
        do {
            let stringNd = message as? String
            var jsonString:Data?
            if stringNd == nil {
                let messageObject = message as AnyObject
                let rawAddress = messageObject["address"]! as! String
                let rawBlockHash = messageObject["blockHash"]! as! String
                let rawBlockNumber = messageObject["blockNumber"]! as! String
                let rawData = messageObject["data"]! as! String
                let rawLogIndex = messageObject["logIndex"]! as! String
                let rawRemoved = messageObject["removed"]! as! Bool
                
                let rawTopics = messageObject["topics"]! as! [String]
                let rawTransactionHash = messageObject["transactionHash"]! as! String
                let rawTransactionIndex = messageObject["transactionIndex"]! as! String
                
                result = SubscribtionResult(logIndex: rawLogIndex, transactionIndex: rawTransactionIndex, transactionHash: rawTransactionHash, blockHash: rawBlockHash, blockNumber: rawBlockNumber, address: rawAddress, data: rawData, topics: rawTopics, type: "", removed: rawRemoved)
                
            }else{
                jsonString = stringNd!.data(using: .utf8)!
                // try decoding as subsciption meta data
                let meta: SubscribtionMeta? = try? JSONDecoder().decode(SubscribtionMeta.self, from: jsonString!)
                // if id is nil then try a different decoder
                if meta!.id != nil {return} // This can be used to unsubscribe to events
                // decode as subsciption topic
                let event: SubscriptionLog? = try? JSONDecoder().decode(SubscriptionLog.self, from: jsonString!)
                
                if event == nil {
                    let jsonData = try! JSONSerialization.data(withJSONObject: message, options: [])
                    result = try? JSONDecoder().decode(SubscribtionResult.self, from: jsonData)
                }else{
                    result = event!.params.result
                }
            }

        }
        
        print(result!)
        
        let stringData = "\(result!.data!)"
        
        // Under 38 charaters is a subscribtion id
        // NOTE: Subscribtion ID will need to be used when unsubscribtion to contract events (Topics)
        if stringData.count > 38 {
            let stringComponts = stringData.components(separatedBy: "000000000000000000000000")
            let stringAddress = "\(stringComponts[0])\(stringComponts[1])"
            
            let addressData = EthereumAddress(stringAddress)
            
            // Discharge incoming topics if driver is not ready for new rides
            if role == .driver && driverListenForRides == false {return}
            
            let topicId = result!.topics[0] as AnyObject
            let messageTopic = "\(topicId)"
            // Cases for all event topics
            switch(messageTopic){
            
            case Topics.passengerRequestRide.rawValue:
                if role == .passenger {
                    // Check if rideID matches event rideID
                    if checkRideId(address: addressData!) {
                        changeViewState(state: .passengerRequestRide)
                        getRideState(address: addressData!)
                        // Only update account balance when ether is sent or recived
                        updateAccountBalance()
                    }
                }else{
                    rideID = addressData
                    changeViewState(state: .passengerRequestRide)
                    getRideState(address: addressData!)
                }
            // TODO: Optimize
            case Topics.driverAccpetsRide.rawValue:
                if checkRideId(address: addressData!) {
                    changeViewState(state: .driverAcceptsRide)
                }
            case Topics.passengerConfirmsPickUp.rawValue:
                if checkRideId(address: addressData!) {
                    changeViewState(state: .passengerConfirmsPickUp)
                }
            case Topics.driverConfirmsDropOff.rawValue:
                if checkRideId(address: addressData!) {
                    changeViewState(state: .driverConfirmsDropOff)
                    updateAccountBalance()
                }
            case Topics.cancelRide.rawValue:
                // Cancel ride Event
                if checkRideId(address: addressData!) {
                    
                    changeViewState(state: .cancelRide)
                    clearMap()
                    // Alert ride cancelation
                    let alert = UIAlertController(title: "Ride Cancelation", message: "Ride has been canceled.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    if role == .driver{
                        rideID = nil // Set rideID back to nil
                    }
                    // Update balance label as funds are returned or split
                    updateAccountBalance()
                }
            default:
                print("Received Unknown topic")
            }
        }
    }
    
    func gotError(error: Error) {
        // TODO handle socket errors
        print("socket error \(error)")
    }
    
    
    // MARK: MapView Compoents
    
    // MARK: MapView MKOverlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = primaryColor.withAlphaComponent(0.3)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
                            locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: clearMap
    // Clears all annoations and overlays currently being displayed
    func clearMap() {
        // check if one of are annotations is nil
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
    }
    
    // MARK: createAnnotation
    // Creates and displays annoations on the map
    func createAnnotation(address:String,title:String) {
        let point = MKPointAnnotation()
        point.title = title
        // Reverse geo code address to coordinates
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            
            else {
                // handle no location found
                print("No location found for address")
                return
            }
            // Set annotation location to address coordinates
            point.coordinate = location.coordinate
            
            // Add annotation to mapView
            self.mapView.addAnnotation(point)
            
            // Keep pickUp and dropOff annotations
            if title == "Pick Up" {
                self.pickUpAnnotation = point
            }else{
                self.dropOffAnnotation = point
            }
            // Check if we have two coordinate points to calculate route
            if self.pickUpAnnotation != nil && self.dropOffAnnotation != nil {
                self.showRouteOnMap(pickupCoordinate: self.pickUpAnnotation!.coordinate, destinationCoordinate: self.dropOffAnnotation!.coordinate)
            }
        }
    }
    
    // MARK: showRouteOnMap
    // Calculates route between two coordinate points
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        // Build direction request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            //for getting just one route
            if let route = unwrappedResponse.routes.first {
                
                // hold onto overlay
                self.driveRoute = route
                //show on map
                self.mapView.addOverlay(route.polyline)
                //set the map area to show the route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                
            }
            //if you want to show multiple routes then you can get all routes in a loop in the following statement
            //for route in unwrappedResponse.routes {}
        }
    }
}
