//
//  IDPCropView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "IDPPhotoCropEditorConstants.h"

@protocol IDPCropViewDelegate;
@protocol IDPCropViewCropDataDelegate;

@interface IDPCropView : UIView

@property (nonatomic) UIImage *image;
@property (nonatomic, readonly) UIImage *croppedImage;
@property (nonatomic, readonly) CGRect zoomedCropRect;
@property (nonatomic, readonly) CGAffineTransform rotation;
@property (nonatomic, readonly) BOOL userHasModifiedCropArea;

@property (nonatomic) BOOL keepingCropAspectRatio;
@property (nonatomic) CGFloat cropAspectRatio;
- (void) setCropAspectRatio:(CGFloat)cropAspectRatio centeringStatus:(IDPCropViewCenteringStatus)centeringStatus;
- (IDPCropViewCenteringStatus) centeringStatus;

@property (assign,nonatomic) IDPCropViewEditMode editMode;
@property (assign,nonatomic) UIEdgeInsets edgeInsets;
@property (strong,nonatomic) UIColor *overlayColor;

@property (nonatomic) CGRect cropRect;

@property (nonatomic) CGFloat rotationAngle;

@property (readonly,nonatomic) BOOL rotationSideways;

- (void)setRotationAngle:(CGFloat)rotationAngle withNormalizeZoomByRotate:(BOOL)normalizeZoomByRotate;

//- (void)setRotationAngle:(CGFloat)rotationAngle snap:(BOOL)snap;

- (void) resetRotationControl;
@property (nonatomic) CGFloat baseDegree; // ベースとなる角度

@property (strong,nonatomic) NSDictionary* cropData;
    // クロップデータ、受け渡す事でデータをやり取り可能

- (BOOL) isFill;
    // Fill チェックメソッド

@property (weak,nonatomic) id<IDPCropViewCropDataDelegate> cropDataDelegate;


@property (weak,nonatomic) id<IDPCropViewDelegate> delegate;

@end

@protocol IDPCropViewDelegate <NSObject>

- (void)cropView:(IDPCropView *)cropRectView didChangedRotationControlRect:(CGRect)rotationControlRect;

- (void)cropView:(IDPCropView *)cropRectView disUpdateRotation:(CGFloat)rotation;

@end

@protocol IDPCropViewCropDataDelegate <NSObject>

- (NSDictionary* )cropView:(IDPCropView *)cropView cropData:(NSDictionary* )cropData scrollView:(UIScrollView *)scrollView zoomingView:(UIView *)zoomingView imageView:(UIImageView *)imageView;

@end

