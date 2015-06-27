//
//  File.swift
//  Bring the Food
//
//  Created by Stefano Bodini on 14/06/15.
//  Copyright (c) 2015 Federico Badini, Stefano Bodini. All rights reserved.
//

import Foundation
import UIKit


/*
    Esegue il download dalla url con cui è stato inizializzato.
    La politica di caching assicura che ogni immagine sia scaricata al più una volta dal server.
    Fatto questo, invia una notifica, il cui stato segnala se il download è andato a buon fine.
*/

public class ImageDownloader{
    
    private let url:String!
    private var image: UIImage?
    
    public init(url:String!){
        self.url = url
    }
    
    public func downloadImage(){
        RestInterface.getInstance().downloadImage(self.url, imDownloader: self)
    }
    
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
    
    public func getImage() -> UIImage?{
        return self.image
    }

}

