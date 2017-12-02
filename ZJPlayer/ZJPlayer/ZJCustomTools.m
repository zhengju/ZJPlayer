//
//  ZJCustomTools.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/26.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJCustomTools.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJCacheTask.h"
@implementation ZJCustomTools
#pragma 获取视频第一帧 返回图片
+ (UIImage*) getVideoPreViewImage:(NSURL *)path
{

    //判断是否有缓存
    UIImage * Img = [[ZJCacheTask shareTask] imageWith:path.absoluteString];
    if (Img) {
        return Img;
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    //缓存
    [[ZJCacheTask shareTask] cacheImageWith:path.absoluteString image:videoImage];
    return videoImage;
}
#pragma mark -- 截屏
+ (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (UIImage *)fetchScreenshot:(CALayer *)layer {
    UIImage *image = nil;
    if (layer) {
        CGSize imageSize = layer.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}
/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
+ (UIImage *)thumbnailImageRequest:(CGFloat )timeBySecond url:(NSString *)urlStr{
    //创建URL
    NSURL *url=[ZJCustomTools getNetworkUrl:urlStr];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    
    CGImageRelease(cgImage);
    return image;
}
/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
+ (NSURL *)getNetworkUrl:(NSString *)urlStr{
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
@end
