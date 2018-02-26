//
//  MediaManager.swift
//  AlphaVideoDemo
//
//  Created by Morshed Alam on 4/11/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//
import Alamofire
import SwiftyJSON

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}




import Foundation


class GGMediaManager {
    
    var apath = ""
    var rgbPath = ""
    
    var didResoureLoaded:((_ isReady: Bool )->Void)?
    
    var resLoader:AVAssetJoinAlphaResourceLoader?
    var media: AVAnimatorMedia?
    
    class func mediaManager() -> GGMediaManager {
        return GGMediaManager()
    }
    
    func setVideoPath(data:JSON){
        if let val = data.array{
            for a in val.enumerated(){
                if a.offset  == 0{
                    if let d = a.element.dictionary{
                        guard let name = d["animation_name"]?.string, let aUrl  = d["a_url"]?.string, let rgbUrl = d["rgb_url"]?.string else {
                            return
                        }
                if FileManager.default.fileExists(atPath: NSTemporaryDirectory().appending("/"+name+".mvid")){
                    let aStr = NSTemporaryDirectory().appending("/"+aUrl+".m4v")
                    let rgbStr = NSTemporaryDirectory().appending("/"+aUrl+".m4v")
            self.makeAlphaAndRgbLoader(rgbResourceName: aStr, alphaResourceName: rgbStr, rgbTmpMvidFilename: name+".mvid")
                
            }else{
                    
                    self.downloadVideoStoreTempDirectory(aOrRgbName: name+"_a", url: aUrl, completion: { (success, path ) in
                        if success {
                            self.apath = (path?.path)!
                            // print(self.apath)
                            self.downloadVideoStoreTempDirectory(aOrRgbName: name+"_rgb", url: rgbUrl, completion: { (success, path ) in
                                if success{
                                    self.rgbPath = (path?.path)!
                                    // print(self.rgbPath)
                                    
                                    self.makeAlphaAndRgbLoader(rgbResourceName: self.rgbPath, alphaResourceName: self.apath, rgbTmpMvidFilename: name+".mvid")
                                    
                                }
                            })
                        }
                        
                    })
                    
                        }
                        
                       
                        
                    }
                    
                }
            }
            
        }

    
    }
    
    
    
    func downloadVideoStoreTempDirectory(aOrRgbName:String,url:String,completion: ((_ status: Bool, _ videoURL: URL?) -> Void)?) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
           
            
            let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
            
            // Create a destination URL.
            let targetURL = tempDirectoryURL.appendingPathComponent(aOrRgbName+".m4v")
            
            
            
            
            //            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            //            let path = documentsURL.appendingPathComponent("mammaStyle/"+aOrRgbName+".m4v")
            
            return (targetURL, [])
        }
        Alamofire.download(url, to: destination).response { response in
            
            if let localURL = response.destinationURL {
                
                completion?(true, localURL)
                
            } else {
                completion?(false, nil)
            }
            
        }
        
    }
    
    
    func makeAlphaAndRgbLoader(rgbResourceName:String,alphaResourceName:String,rgbTmpMvidFilename:String) {
        
        let rgbTmpMvidPath = AVFileUtil.getTmpDirPath(rgbTmpMvidFilename)
        resLoader  = AVAssetJoinAlphaResourceLoader.a()
        resLoader?.movieRGBFilename = rgbResourceName;
        resLoader?.movieAlphaFilename = alphaResourceName;
        resLoader?.outPath = rgbTmpMvidPath;
        resLoader?.alwaysGenerateAdler = true;
        resLoader?.serialLoading = true;
        
        media = AVAnimatorMedia.a()
        media?.resourceLoader = resLoader;
        media?.frameDecoder = AVMvidFrameDecoder.a()
        media?.prepareToAnimate()
        
        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.checkResourseIsLoaded(_:)), userInfo: nil, repeats: true);
        
    }
    
    
    @objc func checkResourseIsLoaded(_ timer:Timer){
    
        if let isReady = self.resLoader?.isReady(), isReady == true{
         timer.invalidate()
            self.didResoureLoaded!(isReady)
            }
            
            
    }
    
    
   }




protocol AnimationDrawerView {
    
}


extension AnimationDrawerView where Self: UIViewController {
    
    func AnimateWithViewAndVideo(media:AVAnimatorMedia) {
        
        let animatorView = AVAnimatorView.aVAnimatorView(withFrame: view.frame)
        
        animatorView?.backgroundColor = UIColor.black
        animatorView?.alpha = 0.7
        animatorView?.contentMode = .scaleAspectFit
        animatorView?.isUserInteractionEnabled =  false
        view.addSubview(animatorView!)
        
        // Deal with Auto Layout
        animatorView?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[animatorView]|", options: [], metrics: nil, views: ["animatorView": animatorView!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[animatorView]|", options: [], metrics: nil, views: ["animatorView": animatorView!]))
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AVAnimatorDoneNotification), object: media, queue: nil) { [unowned self] notification in
            
            self.animatorDoneNotification(notification: notification)
        }
        
        animatorView?.attachMedia(media)
        media.startAnimator()
        
        
        
    }
    
    
    func animatorDoneNotification(notification:Notification){
        let media:AVAnimatorMedia = notification.object as! AVAnimatorMedia
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AVAnimatorDoneNotification), object: media);
        let renderer:AVAnimatorMediaRendererProtocol = media.renderer
        let animatorView = (renderer as! AVAnimatorView)
        media.stopAnimator()
        animatorView.attachMedia(nil)
        animatorView.removeFromSuperview()
        
    }
    
    
    
    
}




