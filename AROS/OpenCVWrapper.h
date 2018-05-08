//
//  OpenCVWrapper.h
//  AROS
//
//  Created by Zura Mestiashvili on 5/7/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGImage.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)toGray:(UIImage *)source;

@end
