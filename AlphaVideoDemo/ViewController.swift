//
//  ViewController.swift
//  AlphaVideoDemo
//
//  Created by Morshed Alam on 4/11/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, AnimationDrawerView {


    /* AlphaVideoDemo_Bridging_Header_h */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func Press(_ sender: Any) {
        
        Alamofire.request("https://jsonblob.com/api/e3da7a00-25af-11e7-ae4c-3df2d6de9f92").responseJSON { response in
            
            if let json = response.result.value {
                
               let ggManager = GGMediaManager.mediaManager()
               ggManager.setVideoPath(data: JSON(json))
                
                ggManager.didResoureLoaded = {[weak self] value in
                    if value == true{
                        self?.AnimateWithViewAndVideo(media: ggManager.media!)
                    }
                
                }
                

            }
        }
        
        
        
        
//        ggManager.makeAlphaAndRgbLoader(rgbResourceName: "revolver.m4v", alphaResourceName: "revolver_a.m4v", rgbTmpMvidFilename: "revolver.mvid")
//        
//        delay(0.1, closure: {
//            
//            
//            
//        })
       

        
    }

   

}

