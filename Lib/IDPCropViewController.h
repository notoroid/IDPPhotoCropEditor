//
//  IDPCropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDPPhotoCropEditorConstants.h"

@interface IDPCropViewController : UIViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic) UIImage *image;

@property (assign,nonatomic) IDPCropViewEditMode editMode;
@property (assign,nonatomic) BOOL toolBarHidden;
@property (assign,nonatomic) UIEdgeInsets edgeInsets;
@property (assign,nonatomic) IDPCropViewFrameType frameType;
- (void) setFrameType:(IDPCropViewFrameType)frameType animated:(BOOL)animated;
@property (strong,nonatomic) UIColor *overlayColor; // オーバーレイの色
@property (strong,nonatomic) UIColor *backgroundColor; //背景色の色
@property (strong,nonatomic) UIBarButtonItem *cancelButton;
@property (strong,nonatomic) UIBarButtonItem *doneButton;

@property (nonatomic) BOOL keepingCropAspectRatio;
@property (nonatomic) CGFloat cropAspectRatio;
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio centeringStatus:(IDPCropViewCenteringStatus)centeringStatus;
- (IDPCropViewCenteringStatus) centeringStatus; // 中央寄せの状態

@property (assign,nonatomic) CGFloat rotationAngle;
@property (readonly,nonatomic) CGFloat baseDegree;
- (void) resetRotate;
- (void) rotate90degree;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) NSDictionary* cropData;

- (void)cancel:(id)sender;
- (void)done:(id)sender;

- (UIImage *) createCroppedImage;

#pragma mark - Utility method
- (NSArray *) degreeToolbarItemsWithAppendButton:(UIBarButtonItem *)appendButton style:(IDPDegreeAdjustmentToolbarStyle)style;

@end

@protocol IDPCropViewControllerDelegate <NSObject>
- (void)cropViewController:(IDPCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage cropData:(NSDictionary*)cropData;
- (void)cropViewControllerDidCancel:(IDPCropViewController *)controller;
@optional
- (CGFloat) cropViewControllerStatusBarHeight:(IDPCropViewController *)controller;
@end
