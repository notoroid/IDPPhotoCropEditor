//
//  IDPCropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDPCropViewControllerDelegate;

@interface IDPCropViewController : UIViewController

@property (nonatomic, weak) id<IDPCropViewControllerDelegate> delegate;
@property (nonatomic) UIImage *image;

@property (nonatomic) BOOL keepingCropAspectRatio;
@property (nonatomic) CGFloat cropAspectRatio;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGRect imageCropRect;

@property (nonatomic) BOOL toolbarHidden;

@property (nonatomic, assign, getter = isRotationEnabled) BOOL rotationEnabled;

@property (nonatomic, readonly) CGAffineTransform rotationTransform;

@property (nonatomic, readonly) CGRect zoomedCropRect;


- (void)resetCropRect;
- (void)resetCropRectAnimated:(BOOL)animated;

@end

@protocol IDPCropViewControllerDelegate <NSObject>
@optional
- (void)cropViewController:(IDPCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)cropViewController:(IDPCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect;
- (void)cropViewControllerDidCancel:(IDPCropViewController *)controller;

@end
