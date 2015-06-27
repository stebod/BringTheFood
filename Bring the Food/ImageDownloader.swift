//
//  File.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit


/// An object of this type has to be instantiated specifically for the 
/// download of a single image, whose url is specified in the initializer.
public class ImageDownloader{
    
    private let url:String!
    private var image: UIImage?
    
    /// :param: url the url of the image that has to be downloaded
    public init(url:String!){
        self.url = url
    }
    
    /// Downloads the image whose url has been specified in the initializer.
    /// When the download is completed, a notification will be posted in
    /// NSNotificationCenter, with the current instance ImageDownloader as
    /// object of the notification. After receiving the notification, it will
    /// be possible to retreive the image using the method getImage()
    public func downloadImage(){
        RestInterface.getInstance().downloadImage(self.url, imDownloader: self)
    }
    
    /// This is the method called by the RestInterface when a response to the 
    /// image download request is received. This method uses the data received
    /// to set the image, and sends a notification to NSNotificationCenter, indicating
    /// if the download succeded.
    public func setImage(data: NSData!, response: NSURLResponse!, error:NSError!){
        
        if(error == nil && data != nil){
            //immagine correttamente disponibile
            self.image = UIImage(data: data)
            NSNotificationCenter.defaultCenter().postNotificationName(
                imageDownloadNotificationKey,
                object: self,
                userInfo: ["info" : HTTPResponseData(RequestStatus.SUCCESS)]
            )
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(
                imageDownloadNotificationKey,
                object: self,
                userInfo: ["info" : HTTPResponseData(RequestStatus.NETWORK_ERROR)]
            )
        }

    }
    
    /// Returns the image that has been downloaded, or nil
    /// if the download hasn't been completed yet
    public func getImage() -> UIImage?{
        return self.image
    }

}

