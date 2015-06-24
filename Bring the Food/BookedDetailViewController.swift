//
//  BookedDetailViewController.swift
//  Bring the Food
//
//  Created by federico badini on 23/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//


import UIKit
import MapKit
import AddressBook

class BookedDetailViewController: UIViewController, MKMapViewDelegate, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainLabel: UILabel!
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
    @IBOutlet weak var dropButton: UIButton!
    
    // Variables populated from prepareForSegue
    var donation: BookedDonation?
    
    // Private variables
    private let regionRadius: CLLocationDistance = 250
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    private var donationPosition: BtfAnnotation?
    
    // Observers
    private weak var userImageObserver: NSObjectProtocol!
    private weak var bookingObserver: NSObjectProtocol!
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        imageDownloader = ImageDownloader(url: donation!.getSupplier().getImageURL())
        // Register notification center observer
        userImageObserver = NSNotificationCenter.defaultCenter().addObserverForName(imageDownloadNotificationKey,
            object: imageDownloader,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.userImageHandler(notification)})
        imageDownloader?.downloadImage()
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
    
    @IBAction func dropButtonPressed(sender: UIButton) {
        bookingObserver = NSNotificationCenter.defaultCenter().addObserverForName(unbookedNotificationKey,
            object: ModelUpdater.getInstance(),
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {(notification:NSNotification!) in self.bookingHandler(notification)})
        donation!.unbook()
    }
    
    // User interface settings
    func setUpInterface() {
        mainLabel.numberOfLines = 2
        mainLabel.text = donation?.getDescription()
        if(donation?.getIsValid() != true){
            dropButton.enabled = false
        }
        infoPanelView.layer.borderColor = UIMainColor.CGColor
        infoPanelView.layer.borderWidth = 1.0
        mapView.layer.borderColor = UIMainColor.CGColor
        mapView.layer.borderWidth = 1.0
        centerMapOnLocation(CLLocation(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        donationPosition = BtfAnnotation(title: donation!.getDescription(),
            offerer: donation!.getSupplier().getName(), address: donation!.getSupplier().getAddress().getLabel()!, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        mapView.addAnnotation(donationPosition)
        mapView.delegate = self
        addressLabel.numberOfLines = 2
        addressLabel.text = donation!.getSupplier().getAddress().getLabel()
        emailLabel.text = donation!.getSupplier().getEmail()
        phoneLabel.text = donation!.getSupplier().getPhone()
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
        }
    }
    
    // Handle unbook response
    func bookingHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Impossible to unbook"
            alert.message = "The donation is not unbookable anymore"
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
            alert.title = "Donation unbooked"
            alert.message = "Top!"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        NSNotificationCenter.defaultCenter().removeObserver(bookingObserver)
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}