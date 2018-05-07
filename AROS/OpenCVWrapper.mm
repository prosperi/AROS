//
//  OpenCVWrapper.mm
//  AROS
//
//  Created by Zura Mestiashvili on 5/7/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
#import "OpenCVWrapper.h"

using namespace cv;


#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (cv::Mat)grayFrom:(cv::Mat)source;

#endif

@end



@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)toGray:(UIImage *)image {
    return [OpenCVWrapper UIImageFromCVMat:[OpenCVWrapper grayFrom:[OpenCVWrapper cvMatFromUIImage:image]]];
}

+ (UIImage *)toNormal:(UIImage *)image {
    return [OpenCVWrapper UIImageFromCVMat:[OpenCVWrapper cvMatFromUIImage:image]];
}


+ (cv::Mat)grayFrom:(cv::Mat)source {
    
    cv::Mat result;
    
   
    cv::cvtColor(source, result, CV_BGR2GRAY);
    
    return result;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4);

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;

}
//
//
//+ (cv::Mat)cvMatFromUIImage:(UIImage *)source {
//    CGImageRef image = CGImageCreateCopy(source.CGImage);
//    CGFloat cols = CGImageGetWidth(image);
//    CGFloat rows = CGImageGetHeight(image);
//    Mat result(rows, cols, CV_8UC4);
//
//    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
//    size_t bitsPerComponent = 8;
//    size_t bytesPerRow = result.step[0];
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
//
//    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
//    CGContextDrawImage(context, CGRectMake(0.0, 0.0, cols, rows), image);
//    CGContextRelease(context);
//    CGImageRelease(image);
//
//    return result;
//
//}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
    
}

+ (UIImage *) UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
