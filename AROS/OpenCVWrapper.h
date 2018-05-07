//
//  OpenCVWrapper.h
//  AROS
//
//  Created by Zura Mestiashvili on 5/7/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;
+ (UIImage *)toGray:(UIImage *)image;
+ (UIImage *)toNormal:(UIImage *)image;

@end
