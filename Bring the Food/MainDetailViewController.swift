//
//  DetailViewController.swift
//  Bring the Food
//
//  Created by federico badini on 18/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class MainDetailViewController: UIViewController, MKMapViewDelegate, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var bookButtonLabel: UILabel!
    @IBOutlet weak var bookButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoPanelView: UIView!
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var foodQuantityLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var quantityKgImageView: UIImageView!
    @IBOutlet weak var quantityLitersImageView: UIImageView!
    @IBOutlet weak var quantityPortionsImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var donorView: UIView!
    @IBOutlet weak var donorViewActivityIndicator: UIActivityIndicatorView!
    
    // Variables populated from prepareForSegue
    var donation: OthersDonation?
    
    // Private variables
    private let regionRadius: CLLocationDistance = 250
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    private var donationPosition: BtfAnnotation?
    private var userImageCollected: Bool = false
    
    // Observers
    private weak var userImageObserver: NSObjectProtocol!
    private weak var bookingObserver: NSObjectProtocol!
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
        imageDownloader = ImageDownloader(url: donation?.getSupplier().getImageURL())
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        // Register notification center observer
        userImageObserver = NSNotificationCenter.defaultCenter().addObserverForName(imageDownloadNotificationKey,
            object: imageDownloader,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.userImageHandler(notification)})
        if(!userImageCollected){
            imageDownloader?.downloadImage()
            donorViewActivityIndicator.startAnimating()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(userImageObserver)
        super.viewWillDisappear(animated)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func bookButtonPressed(sender: UIButton) {
        bookingObserver = NSNotificationCenter.defaultCenter().addObserverForName(bookingCreatedNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.bookingHandler(notification)})
        donation!.book()
        bookButton.enabled = false
        bookButtonLabel.hidden = true
        bookButtonActivityIndicator.startAnimating()
    }
    
    // User interface settings
    func setUpInterface() {
        mainLabel.numberOfLines = 2
        let description = donation!.getDescription()
        var first = description.startIndex
        var rest = advance(first,1)..<description.endIndex
        mainLabel.text = description[first...first].uppercaseString + description[rest]
        infoPanelView.layer.borderColor = UIMainColor.CGColor
        infoPanelView.layer.borderWidth = 1.0
        foodTypeLabel.text = donation!.getProductType().description
        foodQuantityLabel.text = String(stringInterpolationSegment: donation!.getParcelSize())
        let parcelUnit = donation!.getParcelUnit()
        if(parcelUnit == ParcelUnit.KILOGRAMS){
            quantityKgImageView.hidden = false
            quantityLitersImageView.hidden = true
            quantityPortionsImageView.hidden = true
            foodQuantityLabel.text = foodQuantityLabel.text! + " Kg"
        }
        else if(parcelUnit == ParcelUnit.LITERS){
            quantityKgImageView.hidden = true
            quantityLitersImageView.hidden = false
            quantityPortionsImageView.hidden = true
            foodQuantityLabel.text = foodQuantityLabel.text! + " Lt"
        }
        else{
            quantityKgImageView.hidden = true
            quantityLitersImageView.hidden = true
            quantityPortionsImageView.hidden = false
            foodQuantityLabel.text = foodQuantityLabel.text! + " portions"
        }
        expirationLabel.text = String(donation!.getRemainingDays()) + " days left"
        addressLabel.numberOfLines = 2
        mapView.layer.borderColor = UIMainColor.CGColor
        mapView.layer.borderWidth = 1.0
        centerMapOnLocation(CLLocation(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        donationPosition = BtfAnnotation(title: donation!.getDescription(),
            offerer: donation!.getSupplier().getName(), address: donation!.getSupplier().getAddress().getLabel()!, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        mapView.addAnnotation(donationPosition)
        mapView.delegate = self
        donorView.hidden = true
    }
    
    // Center the mapView on the specified location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    // Annotation specification and placement
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? BtfAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -8, y: 0)
                var launchNavigator: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
                launchNavigator.setImage(UIImage(named: "launch_navigator")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: UIControlState.Normal)
                view.rightCalloutAccessoryView = launchNavigator as UIView
            }
            return view
        }
        return nil
    }
    
    // Handle Apple maps opening
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            let location = view.annotation as! BtfAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    // Handles donor image display
    func userImageHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let image = imageDownloader!.getImage()
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.borderWidth = 3.0;
            avatarImageView.layer.borderColor = UIMainColor.CGColor
            // Use smallest side length as crop square length
            var squareLength = min(image!.size.width, image!.size.height)
            var clippedRect = CGRectMake((image!.size.width - squareLength) / 2, (image!.size.height -      squareLength) / 2, squareLength, squareLength)
            avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
            avatarImageView.image = UIImage(CGImage: CGImageCreateWithImageInRect(image!.CGImage, clippedRect))
            userImageCollected = true
        }
        addressLabel.text = donation?.getSupplier().getAddress().getLabel()
        phoneLabel.text = donation?.getSupplier().getPhone()
        emailLabel.text = donation?.getSupplier().getEmail()
        donorViewActivityIndicator.stopAnimating()
        donorView.hidden = false
    }
    
    // Handle booking response
    func bookingHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Impossible to book"
            alert.message = "The donation is not bookable anymore"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        else if(response?.status == RequestStatus.DEVICE_ERROR || response?.status == RequestStatus.NETWORK_ERROR){
            let alert = UIAlertView()
            alert.title = "No connection"
            alert.message = "Check you network connectivity and try again"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        else{
            let alert = UIAlertView()
            alert.title = "Success"
            alert.message = "Booking accomplished!"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        bookButtonActivityIndicator.stopAnimating()
        bookButtonLabel.hidden = false
        bookButton.enabled = true
        NSNotificationCenter.defaultCenter().removeObserver(bookingObserver)
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}


class BtfAnnotation: NSObject, MKAnnotation {
    let title: String
    let subtitle: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, offerer: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = offerer
        self.address = address
        self.coordinate = coordinate
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): address]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}


