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

class MyDetailViewController: UIViewController, MKMapViewDelegate, UIAlertViewDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainLabelRightConstraint: NSLayoutConstraint!
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
    @IBOutlet weak var dropCollectButton: UIButton!
    @IBOutlet weak var dropCollectButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dropCollectButtonLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var collectorView: UIView!
    @IBOutlet weak var collectorViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var missingCollectorLabel: UILabel!
    
    // Variables populated from prepareForSegue
    var donation: MyDonation?
    
    // Private variables
    private let regionRadius: CLLocationDistance = 250
    private var UIMainColor = UIColor(red: 0xf6/255, green: 0xae/255, blue: 0x39/255, alpha: 1)
    private var donationPosition: BtfAnnotation?
    private var collectorDataRetrieved: Bool = false
    
    // Observers
    private weak var userImageObserver: NSObjectProtocol!
    private weak var dropCollectObserver: NSObjectProtocol!
    private weak var collectorObserver: NSObjectProtocol!
    
    // Image downloader
    private var imageDownloader: ImageDownloader?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterface()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        if(donation?.canBeModified() != true){
            // Register notification center observer
            collectorObserver = NSNotificationCenter.defaultCenter().addObserverForName(getCollectorOfDonationNotificationKey,
                object: ModelUpdater.getInstance(),
                queue: NSOperationQueue.mainQueue(),
                usingBlock: {(notification:NSNotification!) in self.handleCollector(notification)})
            if(collectorDataRetrieved == false){
                donation?.downloadDonationCollector()
                collectorViewActivityIndicator.startAnimating()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(donation?.canBeModified() != true){
            if(collectorObserver != nil){
                NSNotificationCenter.defaultCenter().removeObserver(collectorObserver)
            }
            if(userImageObserver != nil){
                NSNotificationCenter.defaultCenter().removeObserver(userImageObserver)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "goToDonationUpdate"){
            var vc = segue.destinationViewController as! ModifyDonationViewController
            vc.donation = donation
        }
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backWithSwipe(sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func dropCollectButtonPressed(sender: AnyObject) {
        if(donation?.getSupplier() == nil){
            let alert = UIAlertView()
            alert.title = "No connection"
            alert.message = "Check you network connectivity and try again"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        else {
            if(donation!.canBeModified() == true){
                dropCollectObserver = NSNotificationCenter.defaultCenter().addObserverForName(donationDeletedNotificationKey,
                    object: ModelUpdater.getInstance(),
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: {(notification:NSNotification!) in self.deleteHandler(notification)})
                donation?.delete()
            }
            else if(donation!.canBeCollected() == true){
                dropCollectObserver = NSNotificationCenter.defaultCenter().addObserverForName(bookingCollectedNotificationKey,
                    object: ModelUpdater.getInstance(),
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: {(notification:NSNotification!) in self.collectHandler(notification)})
                donation?.markAsCollected()
            }
            dropCollectButton.enabled = false
            dropCollectButtonLabel.hidden = true
            dropCollectButtonActivityIndicator.startAnimating()
        }
    }
    
    // User interface settings
    func setUpInterface() {
        mainLabel.numberOfLines = 2
        let description = donation!.getDescription()
        var first = description.startIndex
        var rest = advance(first,1)..<description.endIndex
        mainLabel.text = description[first...first].uppercaseString + description[rest]
        if(donation!.canBeModified() == true){
            editButton.hidden = false
            dropCollectButtonLabel.text = "DROP"
        }
        else {
            dropCollectButtonLabel.text = "COLLECT"
            editButton.hidden = true
            if(donation!.canBeCollected() == false){
                dropCollectButton.hidden = true
                dropCollectButtonLabel.hidden = true
                dropCollectButtonLabel.hidden = true
                mainLabelRightConstraint.constant -= 93
                self.view.layoutIfNeeded()
            }
        }
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
        let remainingDays = donation!.getRemainingDays()
        if(remainingDays > 0){
            expirationLabel.text = String(donation!.getRemainingDays()) + " days left"
        }
        else{
            expirationLabel.text = "expired"
        }
        mapView.layer.borderColor = UIMainColor.CGColor
        mapView.layer.borderWidth = 1.0
        centerMapOnLocation(CLLocation(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        donationPosition = BtfAnnotation(title: donation!.getDescription(),
            offerer: donation!.getSupplier().getName(), address: donation!.getSupplier().getAddress().getLabel()!, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLatitude()!), longitude: CLLocationDegrees(donation!.getSupplier().getAddress().getLongitude()!)))
        mapView.addAnnotation(donationPosition)
        mapView.delegate = self
        addressLabel.numberOfLines = 2
        collectorView.hidden = true
        if(donation?.canBeModified() == true){
            missingCollectorLabel.text = "No collector"
        }
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
            if(image != nil){
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
        collectorViewActivityIndicator.stopAnimating()
        collectorView.hidden = false
        dropCollectButton.enabled = true
    }
    
    // Handle donation collection
    func collectHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Impossible to mark as collected"
            alert.message = "The donation is not markable as collected anymore"
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
            alert.message = "The donation has been marked as collected!"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        NSNotificationCenter.defaultCenter().removeObserver(dropCollectObserver)
        dropCollectButtonActivityIndicator.stopAnimating()
        dropCollectButtonLabel.hidden = false
        dropCollectButton.enabled = true
    }
    
    // Handle donation deletion
    func deleteHandler(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.DATA_ERROR){
            let alert = UIAlertView()
            alert.title = "Impossible to delete donation"
            alert.message = "The donation is not deletable anymore"
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
            alert.message = "The donation has been deleted!"
            alert.addButtonWithTitle("Dismiss")
            alert.delegate = self
            alert.show()
        }
        NSNotificationCenter.defaultCenter().removeObserver(dropCollectObserver)
        dropCollectButtonActivityIndicator.stopAnimating()
        dropCollectButtonLabel.hidden = false
        dropCollectButton.enabled = true
    }
    
    func handleCollector(notification: NSNotification){
        let response = (notification.userInfo as! [String : HTTPResponseData])["info"]
        if(response?.status == RequestStatus.SUCCESS){
            let collector = donation?.getCollector()
            if(collector != nil){
                imageDownloader = ImageDownloader(url: donation!.getSupplier().getImageURL())
                userImageObserver = NSNotificationCenter.defaultCenter().addObserverForName(imageDownloadNotificationKey,
                    object: imageDownloader,
                    queue: NSOperationQueue.mainQueue(),
                    usingBlock: {(notification:NSNotification!) in self.userImageHandler(notification)})
                imageDownloader?.downloadImage()
                addressLabel.text = collector!.getAddress().getLabel()
                emailLabel.text = collector!.getEmail()
                phoneLabel.text = collector!.getPhone()
                collectorView.hidden = false
            }
            else{
                missingCollectorLabel.text = "Uncollected donation"
            }
            collectorDataRetrieved = true
        }
        else{
            missingCollectorLabel.text = "Unable to retrieve collector"
        }
        collectorViewActivityIndicator.stopAnimating()
    }
    
    // AlertView delegate
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        self.navigationController?.popViewControllerAnimated(true)
    }
}


