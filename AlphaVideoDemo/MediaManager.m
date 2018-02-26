//
//  MediaManager.m
//  Fireworks
//
//  Created by Mo DeJong on 10/3/15.
//  Copyright © 2015 helpurock. All rights reserved.
//

#import "MediaManager.h"

#import "AutoTimer.h"

#import "AVFileUtil.h"

#import "AVMvidFrameDecoder.h"
#import "AVAnimatorMedia.h"

// Specific kind of resource to mvid converter to use

#import "AVAsset2MvidResourceLoader.h"

#import "AVAssetJoinAlphaResourceLoader.h"

@interface MediaManager ()

@end

@implementation MediaManager

+ (MediaManager*) mediaManager
{
    return [[MediaManager alloc] init];
}



- (void) makeH264RGBAlphaLoaders
{
    NSString *rgbResourceName;
    NSString *alphaResourceName;
    NSString *rgbTmpMvidFilename;
    NSString *rgbTmpMvidPath;
    
    AVAssetJoinAlphaResourceLoader *resLoader;
    AVAnimatorMedia *media;
    
    // L12 : single firework
    
    rgbResourceName = @"revolver.m4v";
    alphaResourceName = @"revolver_a.m4v";
    rgbTmpMvidFilename = @"revolver.mvid";
    
    rgbTmpMvidPath = [AVFileUtil getTmpDirPath:rgbTmpMvidFilename];
    
    resLoader = [AVAssetJoinAlphaResourceLoader aVAssetJoinAlphaResourceLoader];
    
    resLoader.movieRGBFilename = rgbResourceName;
    resLoader.movieAlphaFilename = alphaResourceName;
    resLoader.outPath = rgbTmpMvidPath;
    resLoader.alwaysGenerateAdler = TRUE;
    resLoader.serialLoading = TRUE;
    
    media = [AVAnimatorMedia aVAnimatorMedia];
    media.resourceLoader = resLoader;
    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
    
    NSAssert(resLoader, @"resLoader");
    NSAssert(media, @"media");
    self.L12Loader = resLoader;
    self.L12Media = media;
    
    
    return;
}
//- (void) make3H264RGBAlphaLoaders
//{
//    NSString *rgbResourceName;
//    NSString *alphaResourceName;
//    NSString *rgbTmpMvidFilename;
//    NSString *rgbTmpMvidPath;
//    
//    AVAssetJoinAlphaResourceLoader *resLoader;
//    AVAnimatorMedia *media;
//    
//    // L12 : single firework
//    
//    rgbResourceName = @"out.m4v";
//    alphaResourceName = @"out_a.m4v";
//    rgbTmpMvidFilename = @"out.mvid";
//    
//    rgbTmpMvidPath = [AVFileUtil getTmpDirPath:rgbTmpMvidFilename];
//    
//    resLoader = [AVAssetJoinAlphaResourceLoader aVAssetJoinAlphaResourceLoader];
//    
//    resLoader.movieRGBFilename = rgbResourceName;
//    resLoader.movieAlphaFilename = alphaResourceName;
//    resLoader.outPath = rgbTmpMvidPath;
//    resLoader.alwaysGenerateAdler = TRUE;
//    resLoader.serialLoading = TRUE;
//    
//    media = [AVAnimatorMedia aVAnimatorMedia];
//    media.resourceLoader = resLoader;
//    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
//    
//    NSAssert(resLoader, @"resLoader");
//    NSAssert(media, @"media");
//    self.L13Loader = resLoader;
//    self.L13Media = media;
//    
//    
//    return;
//}
//
//- (void) make4H264RGBAlphaLoaders
//{
//    NSString *rgbResourceName;
//    NSString *alphaResourceName;
//    NSString *rgbTmpMvidFilename;
//    NSString *rgbTmpMvidPath;
//    
//    AVAssetJoinAlphaResourceLoader *resLoader;
//    AVAnimatorMedia *media;
//    
//    // L12 : single firework
//    
//    rgbResourceName = @"OUT50.m4v";
//    alphaResourceName = @"OUT50_a.m4v";
//    rgbTmpMvidFilename = @"OUT50.mvid";
//    
//    rgbTmpMvidPath = [AVFileUtil getTmpDirPath:rgbTmpMvidFilename];
//    
//    resLoader = [AVAssetJoinAlphaResourceLoader aVAssetJoinAlphaResourceLoader];
//    
//    resLoader.movieRGBFilename = rgbResourceName;
//    resLoader.movieAlphaFilename = alphaResourceName;
//    resLoader.outPath = rgbTmpMvidPath;
//    resLoader.alwaysGenerateAdler = TRUE;
//    resLoader.serialLoading = TRUE;
//    
//    media = [AVAnimatorMedia aVAnimatorMedia];
//    media.resourceLoader = resLoader;
//    media.frameDecoder = [AVMvidFrameDecoder aVMvidFrameDecoder];
//    
//    NSAssert(resLoader, @"resLoader");
//    NSAssert(media, @"media");
//    self.L14Loader = resLoader;
//    self.L14Media = media;
//    
//    
//    return;
//}




- (void) makeLoaders
{
   // [self makeH264Loaders];
    [self makeH264RGBAlphaLoaders];
   // [self make3H264RGBAlphaLoaders];
    //[self make4H264RGBAlphaLoaders];


    
}

- (AVAsset2MvidResourceLoader*) loaderFor24BPPH264:(NSString*)resFilename
                                       outFilename:(NSString*)outFilename
{
    AVAsset2MvidResourceLoader *loader = [AVAsset2MvidResourceLoader aVAsset2MvidResourceLoader];
    
    loader.movieFilename = resFilename;
    
    // Generate fully qualified path in tmp dir
    
    NSString *outPath = [AVFileUtil getTmpDirPath:outFilename];
    loader.outPath = outPath;
    
    return loader;
}

// Return array of all active media objects

- (NSArray*) getAllMedia
{
    NSMutableArray *mArr = [NSMutableArray array];
    
//    [mArr addObject:self.wheelMedia];
//    [mArr addObject:self.redMedia];
  //  [mArr addObjectsFromArray:[self getFireworkMedia]];
    
    [mArr addObject:self.L12Media];
//     [mArr addObject:self.L13Media];
//     [mArr addObject:self.L14Media];
    
    
    
    return mArr;
}

// Return array of all alpha channel fireworks media

//- (NSArray*) getFireworkMedia
//{
//    return @[self.L12Media, self.L22Media, self.L32Media, self.L42Media, self.L52Media, self.L62Media, self.L92Media, self.L112Media];
//}

- (void) startAsyncLoading
{
    // Kick off async loading that will read .h264 and write .mvid to disk in tmp dir.
    // Note that this method can kick off multiple pending timer events so it is useful
    // if this method is not invoked in the initial viewDidLoad or init logic for the
    // app startup.
    
    for (AVAnimatorMedia *media in [self getAllMedia]) {
        [media prepareToAnimate];
    }
}

// Check to see if all loaders are ready now

- (BOOL) allLoadersReady
{
    BOOL allReady = TRUE;
    
    for (AVAnimatorMedia *media in [self getAllMedia]) {
        AVResourceLoader *loader = media.resourceLoader;
        if (loader.isReady == FALSE) {
            allReady = FALSE;
        }
    }
    
    return allReady;
}

@end
