//
//  UIImage+IDPCrop.m
//
//  Created by 能登 要 on 2013/11/04.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UIImage+IDPCrop.h"

@import CoreImage;
@import ImageIO;

@implementation UIImage (IDPCrop)

- (CGFloat) degreesToRadians:(CGFloat) degrees
{
    return degrees * M_PI / 180;
}

- (CGFloat) radiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}


- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)rotation sideways:(BOOL)sideways croppedToRect:(CGRect)rect
{
    UIImage *image = nil;
    
    static BOOL isSimulator = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isSimulator = [[[UIDevice currentDevice] model] hasSuffix:@"Simulator"];
    });
    
    if( sideways != YES && isSimulator != YES ){
        @autoreleasepool {
            CIImage *sourceImage = [[CIImage alloc] initWithCGImage:self.CGImage options:nil];
            switch (self.imageOrientation) {
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                if( self.imageOrientation == UIImageOrientationUpMirrored ){
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(1.0f, -1.0f)];
                }
                break;
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
            {
                sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeRotation([self degreesToRadians:180.0f])];
                if( self.imageOrientation == UIImageOrientationDownMirrored ){
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(1.0f, -1.0f)];
                }
                CGPoint offset = [sourceImage extent].origin;
                sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-offset.x,-offset.y)];
                NSLog(@"[sourceImage extent]=%@",[NSValue valueWithCGRect:[sourceImage extent]]);
            }
                break;
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                {
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeRotation([self degreesToRadians:-90.0f])];
                    if( self.imageOrientation == UIImageOrientationRightMirrored ){
                        sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(-1.0f, 1.0f)];
                    }
                    CGPoint offset = [sourceImage extent].origin;
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-offset.x,-offset.y)];
                    NSLog(@"[sourceImage extent]=%@",[NSValue valueWithCGRect:[sourceImage extent]]);
                }
                break;
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                {
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeRotation([self degreesToRadians:90.0f])];
                    if( self.imageOrientation == UIImageOrientationLeftMirrored ){
                        sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(-1.0f, 1.0f)];
                    }
                    CGPoint offset = [sourceImage extent].origin;
                    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-offset.x,-offset.y)];
                }
                break;
            default:
                break;
            }
            
            CIImage *filteredImage = [sourceImage imageByApplyingTransform:rotation];
            CGRect screenFrame = [filteredImage extent];
            CGRect nonFlippedRect = rect;

            nonFlippedRect.origin.y = screenFrame.size.height - rect.origin.y - rect.size.height;
            filteredImage = [filteredImage imageByCroppingToRect:nonFlippedRect];
                // 右上座標から左下座標へ変更
            
            
            
            
            
          CIContext *ciContext = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:@NO forKey:kCIContextUseSoftwareRenderer]];
          CGImageRef imageRef = [ciContext createCGImage:filteredImage fromRect:[filteredImage extent]];
          image = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:/*self.imageOrientation*/ UIImageOrientationUp];
          CGImageRelease(imageRef);
        }
    }else{
        UIImage *rotatedImage = [self rotatedImageWithtransform:rotation sideways:sideways];
        
        CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
        image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:rotatedImage.imageOrientation];
        CGImageRelease(croppedImage);
    }

    return image;
}

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)transform sideways:(BOOL)sideways
{
    CGSize size = self.size;
    CGSize drawSize = self.size;

    CGPoint offset = CGPointZero;
    if( sideways ){
        size = CGSizeMake(MAX(self.size.width,self.size.height), MAX(self.size.width,self.size.height));
        offset = CGPointMake((size.width - self.size.width) * .5f, (size.height - self.size.height) * .5f);
    }
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [self drawInRect:CGRectMake(offset.x,offset.y, drawSize.width, drawSize.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)rotation
                         croppedToRect:(CGRect)rect
{
    UIImage *rotatedImage = [self rotatedImageWithtransform:rotation];
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    return image;
}

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)transform
{
    CGSize size = self.size;
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

@end
