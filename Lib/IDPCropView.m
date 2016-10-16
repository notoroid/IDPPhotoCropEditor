//
//  IDPCropView.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "IDPPhotoCropEditorConstants.h"
#import "IDPCropView.h"
#import "IDPCropRectView.h"
#import "UIImage+IDPCrop.h" // UIImage+PECrop の横倒し対応版
#import "IDPResizeControl.h"

#define IDP_CROP_VIEW_NAME @"cropview"
#define IDP_CROP_VIEW_FRAME_NAME @"frame"
#define IDP_CROP_VIEW_SCROLL_CONTENT_OFFSET_NAME @"scrollContentOffset"
#define IDP_CROP_VIEW_SCROLL_ZOOMING_SCALE_NAME @"scrollZoomingScale"
#define IDP_CROP_VIEW_ROTATION_ANGLE_NAME @"rotationAngle"
#define IDP_CROP_VIEW_ROTATE_SIDEWAYS_NAME @"rotationSideways"

#define IDP_CROP_VIEW_ZOOMING_VIEW_FRAME_NAME @"zoomingViewFrame"
#define IDP_CROP_VIEW_SCROLL_CONTENT_SIZE_NAME @"scrollContentSize"
#define IDP_CROP_VIEW_SCROLL_MINIMUM_ZOOM_SCALE_NAME @"minimumZoomScale"

#define IDP_CROP_VIEW_ROTATE_CONTROL_LOCK_DIRECTION_NAME @"rotate-control-lock-direction"
#define IDP_CROP_VIEW_ROTATE_CONTROL_HORIZONTAL_RATIO_NAME @"rotate-control-horizontal-ratio"
#define IDP_CROP_VIEW_ROTATE_CONTROL_VERTICAL_RATIO_NAME @"rotate-control-vertical-ratio"
#define IDP_CROP_VIEW_ROTATE_CONTROL_BASE_DEGREE_NAME @"rotate-control-base-degree"

CGFloat degreesToRadians3(CGFloat degrees);
CGFloat degreesToRadians3(CGFloat degrees) {return degrees * M_PI / 180;};

CGFloat radiansToDegrees3(CGFloat radians);
CGFloat radiansToDegrees3(CGFloat radians) {return radians * 180 / M_PI;};

@interface IDPCropView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL _rotationSideways;
    IDPCropViewEditMode _editMode;
    UIColor *_overlayColor;
    NSValue* _originalScrolViewFrame;
}

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *zoomingView;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic) IDPCropRectView *cropRectView;
@property (nonatomic) UIView *topOverlayView;
@property (nonatomic) UIView *leftOverlayView;
@property (nonatomic) UIView *rightOverlayView;
@property (nonatomic) UIView *bottomOverlayView;

@property (nonatomic) CGRect insetRect;
@property (nonatomic) CGRect editingRect;

@property (nonatomic, getter = isResizing) BOOL resizing;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation IDPCropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor clearColor];
 
    self.edgeInsets = UIEdgeInsetsMake(IDP_CROP_VERTICAL_MARGINE,IDP_CROP_HORIZONTAL_MARGINE,IDP_CROP_VERTICAL_MARGINE,IDP_CROP_HORIZONTAL_MARGINE);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.maximumZoomScale = 20.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.scrollEnabled = _editMode == IDPCropViewEditModeAngleAdjustment ? NO : YES;
    self.scrollView.userInteractionEnabled = _editMode == IDPCropViewEditModeAngleAdjustment ? NO : YES;
    [self addSubview:self.scrollView];

//#ifdef DEBUG    
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
//    rotationGestureRecognizer.delegate = self;
//    [self.scrollView addGestureRecognizer:rotationGestureRecognizer];
//#endif
    
    
//#ifdef DEBUG
//    
//#else
    self.topOverlayView = [[UIView alloc] init];
    self.topOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    [self addSubview:self.topOverlayView];
    
    self.leftOverlayView = [[UIView alloc] init];
    self.leftOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    [self addSubview:self.leftOverlayView];
    
    self.rightOverlayView = [[UIView alloc] init];
    self.rightOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    [self addSubview:self.rightOverlayView];
    
    self.bottomOverlayView = [[UIView alloc] init];
    self.bottomOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    [self addSubview:self.bottomOverlayView];
//#endif

    if( _editMode == IDPCropViewEditModeAngleAdjustment ){
        _cropRectView = [[IDPCropRectView alloc] init];
        
        _cropRectView.delegate = self;
        [self addSubview:_cropRectView];
    }
    
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        return nil;
    }
    
    UIView *hitView = [self.cropRectView hitTest:[self convertPoint:point toView:self.cropRectView] withEvent:event];
    if (hitView) {
        return hitView;
    }
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale);
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
        return self.scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.image) {
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    
    CGRect bounds = self.bounds;
    CGRect editingRect = CGRectZero;
    editingRect = UIEdgeInsetsInsetRect(bounds,_edgeInsets);
    
    self.editingRect = editingRect;
//    NSLog(@"editingRect=%@",[NSValue valueWithCGRect:editingRect]);
    
    if (!self.imageView) {
        
        CGRect insetRect = CGRectZero;
        insetRect = UIEdgeInsetsInsetRect(bounds,_edgeInsets);
        self.insetRect = insetRect;
        
        [self setupImageView];
    }
    
    if (!self.isResizing) {
        //        NSLog(@"self.scrollView.frame=%@",[NSValue valueWithCGRect:self.scrollView.frame]);
        [self layoutCropRectViewWithCropRect:self.scrollView.frame];
        
        if (self.interfaceOrientation != interfaceOrientation) {
            [self zoomToCropRect:self.scrollView.frame toFill:NO force:NO centeringStatus:IDPCropViewCenteringStatusBoth | IDPCropViewCenteringStatusNoAnimation];
        }
    }
    
    self.interfaceOrientation = interfaceOrientation;
}

- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect
{
    CGRect cropRectFrame = CGRectMake( CGRectGetMinX(self.scrollView.frame)
                                      ,CGRectGetMinY(self.scrollView.frame)
                                      ,CGRectGetWidth(self.scrollView.frame) * self.cropRectView.horizontalRatio
                                      ,CGRectGetHeight(self.scrollView.frame) * self.cropRectView.verticalRatio);
    
    self.cropRectView.frame = cropRectFrame/*cropRect*/;
    
//    NSLog(@"self.scrollView.frame=%@",[NSValue valueWithCGRect:self.scrollView.frame]);
    
    [self layoutOverlayViewsWithCropRect:cropRect];
}

- (void)layoutOverlayViewsWithCropRect:(CGRect)cropRect
{
    self.topOverlayView.frame = CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth(self.bounds),
                                           CGRectGetMinY(cropRect));
    self.leftOverlayView.frame = CGRectMake(0.0f,
                                            CGRectGetMinY(cropRect),
                                            CGRectGetMinX(cropRect),
                                            CGRectGetHeight(cropRect));
    self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(cropRect),
                                             CGRectGetMinY(cropRect),
                                             CGRectGetWidth(self.bounds) - CGRectGetMaxX(cropRect),
                                             CGRectGetHeight(cropRect));
    self.bottomOverlayView.frame = CGRectMake(0.0f,
                                              CGRectGetMaxY(cropRect),
                                              CGRectGetWidth(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMaxY(cropRect));
}

- (void)setupImageView
{
    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect);
    
    self.scrollView.bounds = cropRect;
    self.scrollView.contentSize = cropRect.size;
//#ifdef DEBUG
//    self.scrollView.backgroundColor = [UIColor redColor];
//#endif
    self.zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.zoomingView.backgroundColor = [UIColor clearColor];
//#ifdef DEBUG
//    self.zoomingView.backgroundColor = [UIColor blueColor];
//    self.zoomingView.opaque = NO;
//    self.zoomingView.alpha = .5f;
//#endif
    [self.scrollView addSubview:self.zoomingView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
//#ifdef DEBUG
//    self.imageView.backgroundColor = [UIColor greenColor];
//    self.imageView.opaque = NO;
//    self.imageView.alpha = .5f;
//#endif
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
//#ifdef DEBUG
//    self.imageView.image = nil;
//#else
    self.imageView.image = self.image;
//#endif
    
    [self.zoomingView addSubview:self.imageView];
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.zoomingView removeFromSuperview];
    self.zoomingView = nil;
    
    [self setNeedsLayout];
}

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropRectView.keepingAspectRatio = self.keepingCropAspectRatio;
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio
{
    [self setCropAspectRatio:cropAspectRatio centeringStatus:IDPCropViewCenteringStatusBoth];
}

- (void) setCropAspectRatio:(CGFloat)cropAspectRatio centeringStatus:(IDPCropViewCenteringStatus)centeringStatus
{
//    NSLog(@"self.scrollView.frame=%@",[NSValue valueWithCGRect:self.scrollView.frame]);
    if( _originalScrolViewFrame == nil ){
        _originalScrolViewFrame = [NSValue valueWithCGRect:self.scrollView.frame];
    }
    
    CGRect cropRect = [_originalScrolViewFrame CGRectValue];
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    CGRect frame = [_originalScrolViewFrame CGRectValue];
    
    CGFloat horizontalMargine = .0f;
    CGFloat verticalMargine = .0f;
    
    CGFloat ratioFrame = frame.size.width / frame.size.height;
    if( cropAspectRatio < ratioFrame ){
        CGFloat height = frame.size.height;
        CGFloat width = height * cropAspectRatio;
        
        horizontalMargine = (frame.size.width - width) * .5f;
        verticalMargine = (frame.size.height - height) * .5f;
    }else{
        CGFloat width = frame.size.width;
        CGFloat height = width / cropAspectRatio;
        
        horizontalMargine = (frame.size.width - width) * .5f;
        verticalMargine = (frame.size.height - height) * .5f;
    }
    
    cropRect.size = CGSizeMake(width - horizontalMargine * 2.0f, height - verticalMargine * 2.0f);
//    NSLog(@"cropRect=%@",[NSValue valueWithCGRect:cropRect]);
    
    [self zoomToCropRect:cropRect toFill:YES force:NO centeringStatus:centeringStatus];
}

- (CGPoint) generateCenteringPosition
{
    CGPoint centeringPosition = CGPointMake(
                                    (CGRectGetWidth(self.zoomingView.frame) - CGRectGetWidth(self.scrollView.frame)) * .5f
                                    ,(CGRectGetHeight(self.zoomingView.frame) - CGRectGetHeight(self.scrollView.frame)) * .5f );
    
    return centeringPosition;
}

- (IDPCropViewCenteringStatus) centeringStatus
{
    CGPoint testContentOffset = [self generateCenteringPosition];
    
    NSInteger status = 0;
    status |= (self.scrollView.contentOffset.x == testContentOffset.x ? IDPCropViewCenteringStatusHorizontal :0 );
    status |= (self.scrollView.contentOffset.y == testContentOffset.y ? IDPCropViewCenteringStatusVertical :0 );
    
    return status;
}

- (CGFloat)cropAspectRatio
{
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    return width / height;
}

- (IDPCropViewEditMode) editMode
{
    return _editMode;
}

- (void) setEditMode:(IDPCropViewEditMode)editMode
{
    _editMode = editMode;
    
    self.userInteractionEnabled = (_editMode == IDPCropViewEditModeAngleAdjustmentNoTracker) ? NO : YES;
    
    self.scrollView.scrollEnabled = (_editMode == IDPCropViewEditModeAngleAdjustment) ? NO : YES;
    self.scrollView.userInteractionEnabled = (_editMode == IDPCropViewEditModeAngleAdjustment) ? NO : YES;
    
    if( _editMode == IDPCropViewEditModeAngleAdjustment && self.cropRectView == nil ){
        _cropRectView = [[IDPCropRectView alloc] init];
        _cropRectView.delegate = self;
        [self addSubview:_cropRectView];
    }else if( _editMode != IDPCropViewEditModeAngleAdjustment && self.cropRectView != nil ){
        [_cropRectView removeFromSuperview];
        _cropRectView = nil;
    }
    
}

- (UIColor *) overlayColor
{
    return _overlayColor;
}

- (void) setOverlayColor:(UIColor *)overlayColor
{
    _overlayColor = overlayColor;
    
    self.topOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    self.leftOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    self.rightOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
    self.bottomOverlayView.backgroundColor = _overlayColor != nil ? _overlayColor :[UIColor colorWithWhite:0.0f alpha:0.4f];
}

- (void)setCropRect:(CGRect)cropRect
{
    [self zoomToCropRect:cropRect toFill:NO force:NO centeringStatus:IDPCropViewCenteringStatusBoth];
}

- (CGRect)cropRect
{
    return self.scrollView.frame;
}

- (UIBezierPath *)hittestBezierPath
{
    CGRect imageBounds = self.imageView.bounds;
    imageBounds = CGRectMake(.0f,.0f, imageBounds.size.width + .0f, imageBounds.size.height + .0f);
    
    UIBezierPath* rectanglePath = nil;
    rectanglePath = [UIBezierPath bezierPathWithRect:imageBounds];
//    NSLog(@"1) rectanglePath.bounds=%@",[NSValue valueWithCGRect:rectanglePath.bounds]);
    
    [rectanglePath applyTransform:self.rotation];
    //    NSLog(@"rectanglePath.bounds=%@",[NSValue valueWithCGRect:rectanglePath.bounds]);
    
    CGPoint translation = CGPointMake( - (CGRectGetMidX(rectanglePath.bounds) - CGRectGetMidX(imageBounds))
                                      ,- (CGRectGetMidY(rectanglePath.bounds) - CGRectGetMidY(imageBounds)) );
    [rectanglePath applyTransform:CGAffineTransformMakeTranslation(
                                                                   translation.x
                                                                   ,translation.y ) ];
//    NSLog(@"2) rectanglePath.bounds=%@",[NSValue valueWithCGRect:rectanglePath.bounds]);
    
    return rectanglePath;
}

- (BOOL) isFill
{
    UIBezierPath* rectanglePath = [self hittestBezierPath];
    
    CGRect maskRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
//    NSLog(@"maskRect=%@",[NSValue valueWithCGRect:maskRect]);
    
    CGFloat minX = CGRectGetMinX(maskRect);
    CGFloat minY = CGRectGetMinY(maskRect);
    CGFloat maxX = CGRectGetMaxX(maskRect);
    CGFloat maxY = CGRectGetMaxY(maskRect);
    
    BOOL fill = YES;
    
    if( [rectanglePath containsPoint:CGPointMake(minX, minY)] != YES ||
        [rectanglePath containsPoint:CGPointMake(maxX, minY)] != YES ||
        [rectanglePath containsPoint:CGPointMake(maxX, maxY)] != YES ||
        [rectanglePath containsPoint:CGPointMake(minX, maxY)] != YES
       )
    {
        fill = NO;
    }
    
    
    return fill;
}

- (NSDictionary*) cropData
{
    CGRect zoomedCropRect = self.zoomedCropRect;


    CGRect zoomingViewFrame = self.zoomingView.frame;
    zoomingViewFrame = CGRectMake(  zoomingViewFrame.origin.x / self.scrollView.zoomScale
                                  , zoomingViewFrame.origin.y / self.scrollView.zoomScale
                                  , zoomingViewFrame.size.width / self.scrollView.zoomScale
                                  , zoomingViewFrame.size.height / self.scrollView.zoomScale );
    
    NSDictionary* cropData = @{
                 IDP_CROP_VIEW_NAME:@{
                         // 以前の位置調整コード
                          IDP_CROP_VIEW_FRAME_NAME:[NSValue valueWithCGRect:self.frame]
                         ,IDP_CROP_VIEW_SCROLL_CONTENT_OFFSET_NAME:[NSValue valueWithCGPoint:self.scrollView.contentOffset]
                         ,IDP_CROP_VIEW_SCROLL_ZOOMING_SCALE_NAME:@(self.scrollView.zoomScale)
                         ,IDP_CROP_VIEW_ROTATION_ANGLE_NAME:@(self.rotationAngle)
                         ,IDP_CROP_VIEW_ROTATE_SIDEWAYS_NAME:@(_rotationSideways)
                         
                          // 新規位置調整コード
                         ,IDP_CROP_VIEW_ZOOMING_VIEW_FRAME_NAME:[NSValue valueWithCGRect:zoomingViewFrame/*self.zoomingView.frame*/]
                         ,IDP_CROP_VIEW_SCROLL_CONTENT_SIZE_NAME:[NSValue valueWithCGSize:self.scrollView.contentSize]
                         ,IDP_CROP_VIEW_SCROLL_MINIMUM_ZOOM_SCALE_NAME:@(self.scrollView.minimumZoomScale)
                          
                         // 回転UI用コード
                         ,IDP_CROP_VIEW_ROTATE_CONTROL_LOCK_DIRECTION_NAME:@(self.cropRectView.controlLockDirection)
                         ,IDP_CROP_VIEW_ROTATE_CONTROL_HORIZONTAL_RATIO_NAME:@(self.cropRectView.horizontalRatio)
                         ,IDP_CROP_VIEW_ROTATE_CONTROL_VERTICAL_RATIO_NAME:@(self.cropRectView.verticalRatio)
                         ,IDP_CROP_VIEW_ROTATE_CONTROL_BASE_DEGREE_NAME:@(self.baseDegree)
                         }
                 ,IDP_CROP_ROTATION_NAME:[NSValue valueWithCGAffineTransform:self.rotation]
                 ,IDP_CROP_ZOOMED_CROP_RECT_NAME:[NSValue valueWithCGRect:zoomedCropRect]
                 ,IDP_CROP_SIDEWAYS_NAME:@(_rotationSideways)
                 // 新規位置調整コード
//                 ,NK_PHOTO_CROP_ZOOMED_CROP_OFFSET_NAME:[NSValue valueWithCGPoint:pointCropOffset]
                 };
    
    SEL selCropData = @selector(cropView: cropData: scrollView: zoomingView: imageView:);
    if( [_cropDataDelegate respondsToSelector:selCropData] )
        cropData = [_cropDataDelegate cropView:self cropData:cropData scrollView:self.scrollView zoomingView:self.zoomingView imageView:self.imageView];
    
//    NSLog(@"cropData=%@",cropData );
    
    return cropData;
}

- (void) setCropData:(NSDictionary *)cropData
{
    NSDictionary* cropviewInfo = cropData[IDP_CROP_VIEW_NAME];
    if( cropviewInfo != nil ){
        // 共通の適用項目
        
        NSValue* zoomingViewFrameValue = cropviewInfo[IDP_CROP_VIEW_ZOOMING_VIEW_FRAME_NAME];
        if( zoomingViewFrameValue != nil ){
            [self setRotationAngle:[cropviewInfo[IDP_CROP_VIEW_ROTATION_ANGLE_NAME] floatValue]];
            BOOL rotationSideways = [cropviewInfo[IDP_CROP_VIEW_ROTATE_SIDEWAYS_NAME] boolValue];
            _rotationSideways = rotationSideways;
        }else{
            BOOL rotationSideways = [cropviewInfo[IDP_CROP_VIEW_ROTATE_SIDEWAYS_NAME] boolValue];
            _rotationSideways = rotationSideways;
            
            [self setRotationAngle:[cropviewInfo[IDP_CROP_VIEW_ROTATION_ANGLE_NAME] floatValue] withNormalizeZoomByRotate:YES];
        }
        
        NSValue* scrollContentSizeValue = cropviewInfo[IDP_CROP_VIEW_SCROLL_CONTENT_SIZE_NAME];
        if( scrollContentSizeValue != nil ){
            self.scrollView.contentSize = [scrollContentSizeValue CGSizeValue];
        }
        
        CGRect frame = [cropviewInfo[IDP_CROP_VIEW_FRAME_NAME] CGRectValue];
        if( CGRectEqualToRect(self.frame,frame ) ){
            CGFloat zoomScale = [cropviewInfo[IDP_CROP_VIEW_SCROLL_ZOOMING_SCALE_NAME] floatValue];
            self.scrollView.zoomScale = zoomScale;
            
            NSNumber* valueMinimumZoomScale = cropviewInfo[IDP_CROP_VIEW_SCROLL_MINIMUM_ZOOM_SCALE_NAME];
            if( valueMinimumZoomScale != nil )
                self.scrollView.minimumZoomScale = [valueMinimumZoomScale floatValue];
            
            CGPoint contentOffset = [cropviewInfo[IDP_CROP_VIEW_SCROLL_CONTENT_OFFSET_NAME] CGPointValue];
            self.scrollView.contentOffset = contentOffset;
            
        }else{
            // ここに例外処理を記述する
            CGFloat ratio = self.frame.size.height / frame.size.height;
            // 倍率を計算する
            
            self.scrollView.zoomScale = [cropviewInfo[IDP_CROP_VIEW_SCROLL_ZOOMING_SCALE_NAME] floatValue];
            
            NSNumber* valueMinimumZoomScale = cropviewInfo[IDP_CROP_VIEW_SCROLL_MINIMUM_ZOOM_SCALE_NAME];
            if( valueMinimumZoomScale != nil )
                self.scrollView.minimumZoomScale = [valueMinimumZoomScale floatValue];
            
            CGPoint contentOffset = [cropviewInfo[IDP_CROP_VIEW_SCROLL_CONTENT_OFFSET_NAME] CGPointValue];
            self.scrollView.contentOffset = CGPointMake(contentOffset.x * ratio, contentOffset.y * ratio);
        }
     

        if( zoomingViewFrameValue != nil ){
            CGRect zoomingViewFrame = [zoomingViewFrameValue CGRectValue];
            
            CGFloat zoomScale = [cropviewInfo[IDP_CROP_VIEW_SCROLL_ZOOMING_SCALE_NAME] floatValue];
            self.zoomingView.frame = CGRectMake( zoomingViewFrame.origin.x * zoomScale
                                                ,zoomingViewFrame.origin.y * zoomScale
                                                ,zoomingViewFrame.size.width * zoomScale
                                                ,zoomingViewFrame.size.height * zoomScale
                                                );
            
            self.imageView.center = CGPointMake( self.zoomingView.bounds.size.width * .5f
                                                ,self.zoomingView.bounds.size.height * .5f);
        }else{
            
        }
        
        
        self.cropRectView.controlLockDirection = [cropviewInfo[IDP_CROP_VIEW_ROTATE_CONTROL_LOCK_DIRECTION_NAME] intValue];
        self.cropRectView.horizontalRatio = [cropviewInfo[IDP_CROP_VIEW_ROTATE_CONTROL_HORIZONTAL_RATIO_NAME] floatValue];
        self.cropRectView.verticalRatio = [cropviewInfo[IDP_CROP_VIEW_ROTATE_CONTROL_VERTICAL_RATIO_NAME] floatValue];
        self.baseDegree = [cropviewInfo[IDP_CROP_VIEW_ROTATE_CONTROL_BASE_DEGREE_NAME] floatValue];
    }
}

- (UIImage *)croppedImage
{
    UIImage* result = [self.image rotatedImageWithtransform:self.rotation sideways:self.rotationSideways croppedToRect:self.zoomedCropRect];
        // 横倒し状態を考慮した回転イメージを取得する
    return result;
}

- (CGRect)zoomedCropRect
{
    CGRect cropRect = /*[self convertRect:self.scrollView.frame toView:self.zoomingView]*/ CGRectZero;
    CGFloat ratio = 1.0f;

    CGRect zoomedCropRect = CGRectZero;

    CGSize size = self.image.size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.width;
    } else {
        ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.height;
    }
    
    if( _rotationSideways ){
        cropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
        zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                    cropRect.origin.y / ratio,
                                    cropRect.size.width / ratio,
                                    cropRect.size.height / ratio);

        
        CGPoint offset = CGPointMake(size.width > size.height ? MAX(size.width,size.height) - MIN(size.width,size.height) : .0f,size.width < size.height ? MAX(size.width,size.height) - MIN(size.width,size.height) : .0f);
        
        zoomedCropRect = CGRectOffset(zoomedCropRect, offset.x *.5f, offset.y *.5f);
        
    
    }else{
        cropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
        zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                           cropRect.origin.y / ratio,
                                           cropRect.size.width / ratio,
                                           cropRect.size.height / ratio);
    }
    
    
    return zoomedCropRect;
}

- (BOOL)userHasModifiedCropArea
{
    CGRect zoomedCropRect = CGRectIntegral(self.zoomedCropRect);
    return (!CGPointEqualToPoint(zoomedCropRect.origin, CGPointZero) ||
            !CGSizeEqualToSize(zoomedCropRect.size, self.image.size) ||
            !CGAffineTransformEqualToTransform(self.rotation, CGAffineTransformIdentity));
}

- (CGAffineTransform)rotation
{
    return self.imageView.transform;
}

- (BOOL) rotationSideway
{
    return _rotationSideways;
}

- (CGFloat)rotationAngle
{
    CGAffineTransform rotation = self.imageView.transform;
    return atan2f(rotation.b, rotation.a);
}

- (void)setRotationAngle:(CGFloat)rotationAngle withNormalizeZoomByRotate:(BOOL)normalizeZoomByRotate
{
    self.imageView.transform = CGAffineTransformMakeRotation(rotationAngle);
    if( normalizeZoomByRotate == YES ){
        [self normalizeZoomByRotate];
    }
}

- (void)setRotationAngle:(CGFloat)rotationAngle
{
    [self setRotationAngle:rotationAngle withNormalizeZoomByRotate:YES];
}

- (void) resetRotationControl
{
    self.cropRectView.horizontalRatio = 1.0f;
    self.cropRectView.verticalRatio = 1.0f;
    self.cropRectView.controlLockDirection = IDPCropRectViewLockDirectionNeutoral;
    [self layoutCropRectViewWithCropRect:self.scrollView.bounds ];
}

- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect
{
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0f) {
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self zoomToCropRect:self.cropRectView.frame toFill:NO force:NO centeringStatus:IDPCropViewCenteringStatusBoth];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark -

- (CGRect)cropRectView:(IDPCropRectView *)cropRectView rectForEditingInitialRect:(CGRect)initialRect
{
    initialRect.size = self.scrollView.frame.size;
    return initialRect;
}

- (void)cropRectView:(IDPCropRectView *)cropRectView didChangedRotationControlRect:(CGRect)rotationControlRect
{
    CGRect convertRect = [self convertRect:rotationControlRect fromView:cropRectView];
    [self.delegate cropView:self didChangedRotationControlRect:convertRect];
    
}

- (void)cropRectViewDidBeginEditing:(IDPCropRectView *)cropRectView
{
    self.resizing = YES;
}

- (void)cropRectViewEditingChanged:(IDPCropRectView *)cropRectView
{
    CGFloat degree = 0;
    switch (cropRectView.controlLockDirection) {
        case IDPCropRectViewLockDirectionHorizontal:
        {
            CGFloat ratio = 1;
            if( self.scrollView.frame.size.width - cropRectView.frame.size.width > cropRectView.cropLockMargine ){
                ratio = (cropRectView.frame.size.width - cropRectView.cropLockMargine) / (self.scrollView.frame.size.width - cropRectView.cropLockMargine);
            }
            
            degree = (1.0 -ratio) * -55.0f;
        }
            break;
        case IDPCropRectViewLockDirectionVertical:
        {
            CGFloat ratio = 1;
            if( self.scrollView.frame.size.height - cropRectView.frame.size.height > cropRectView.cropLockMargine ){
                ratio = (cropRectView.frame.size.height - cropRectView.cropLockMargine) / (self.scrollView.frame.size.height - cropRectView.cropLockMargine);
            }
            
            degree = (1.0 - ratio) * 55.0f;
        }
            break;
        default:
            break;
    }
    
    degree = degree + self.baseDegree /*degree90Number * 90.0f*/;
//    NSLog(@"degree=%@",@(degree) );

    self.rotationAngle = degreesToRadians3(degree);
        // 角度を適用

    [self normalizeZoomByRotate];
    
    [self.delegate cropView:self disUpdateRotation:self.rotationAngle];
}

- (void) normalizeZoomByRotate
{
    CGRect maskRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
    
#define MASK_HITTEST_STEP .00125f;
    
    if( [self isFill] == YES ){
        UIBezierPath* hittestBezierPath = [self hittestBezierPath];
        // hittest用のパスを取得
//        NSLog(@"hittestBezierPath.bounds=%@",[NSValue valueWithCGRect:hittestBezierPath.bounds]);
        
        BOOL bFill = YES;
        CGFloat delta = 1.0f;
        
        CGRect preZoomRect = CGRectZero;
        CGRect zoomRect = CGRectZero;
        while (bFill != NO) {
            delta += MASK_HITTEST_STEP;
            
            CGRect hittestRect = CGRectMake( maskRect.origin.x
                                            ,maskRect.origin.y
                                            ,maskRect.size.width * delta
                                            ,maskRect.size.height * delta);
            hittestRect = CGRectOffset(hittestRect
                                       ,(maskRect.size.width - hittestRect.size.width) * .5f
                                       ,(maskRect.size.height - hittestRect.size.height) * .5f );
            
            
            CGFloat minX = CGRectGetMinX(hittestRect);
            CGFloat minY = CGRectGetMinY(hittestRect);
            CGFloat maxX = CGRectGetMaxX(hittestRect);
            CGFloat maxY = CGRectGetMaxY(hittestRect);
            
            bFill = YES;
            if( [hittestBezierPath containsPoint:CGPointMake(minX, minY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(maxX, minY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(maxX, maxY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(minX, maxY)] != YES )
            {
                bFill = NO;
            }
            
            preZoomRect = zoomRect;
            zoomRect = hittestRect;
        }
        
        if( CGRectIsEmpty(preZoomRect) != YES ){
            [self.scrollView zoomToRect:preZoomRect animated:NO];
            [self.scrollView setContentOffset:CGPointMake(
                                        (CGRectGetWidth(self.zoomingView.frame) - CGRectGetWidth(self.scrollView.frame)) * .5f
                                      ,(CGRectGetHeight(self.zoomingView.frame) - CGRectGetHeight(self.scrollView.frame)) * .5f) animated:NO];
        }
    }
    
    if( [self isFill] != YES ){
        UIBezierPath* hittestBezierPath = [self hittestBezierPath];
        // hittest用のパスを取得
//        NSLog(@"hittestBezierPath.bounds=%@",[NSValue valueWithCGRect:hittestBezierPath.bounds]);
        
        BOOL bFill = NO;
        CGFloat delta = 1.0f;
        
        CGRect zoomRect = CGRectZero;
        while (bFill != YES) {
            delta -= MASK_HITTEST_STEP;
            
            CGRect hittestRect = CGRectMake(    maskRect.origin.x
                                            ,maskRect.origin.y
                                            ,maskRect.size.width * delta
                                            ,maskRect.size.height * delta);
            hittestRect = CGRectOffset( hittestRect
                                       ,(maskRect.size.width - hittestRect.size.width) * .5f
                                       ,(maskRect.size.height - hittestRect.size.height) * .5f );
            
            
            CGFloat minX = CGRectGetMinX(hittestRect);
            CGFloat minY = CGRectGetMinY(hittestRect);
            CGFloat maxX = CGRectGetMaxX(hittestRect);
            CGFloat maxY = CGRectGetMaxY(hittestRect);
            
            bFill = YES;
            if( [hittestBezierPath containsPoint:CGPointMake(minX, minY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(maxX, minY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(maxX, maxY)] != YES ||
               [hittestBezierPath containsPoint:CGPointMake(minX, maxY)] != YES )
            {
                bFill = NO;
            }
            
            zoomRect = hittestRect;
        }
        
//        NSLog(@"zoomRect=%@",[NSValue valueWithCGRect:zoomRect]);
        [self.scrollView zoomToRect:zoomRect animated:NO];
        [self.scrollView setContentOffset:CGPointMake(
                                                      (CGRectGetWidth(self.zoomingView.frame) - CGRectGetWidth(self.scrollView.frame)) * .5f
                                                      ,(CGRectGetHeight(self.zoomingView.frame) - CGRectGetHeight(self.scrollView.frame)) * .5f) animated:NO];
    }
    
}

- (void)cropRectViewDidEndEditing:(IDPCropRectView *)cropRectView
{
    self.resizing = NO;

    CGRect bounds = cropRectView.bounds;
    cropRectView.horizontalRatio = bounds.size.width / self.scrollView.bounds.size.width;
    cropRectView.verticalRatio = bounds.size.height / self.scrollView.bounds.size.height;
    
//    NSLog(@"cropRectView.verticalRatio=%@", @(cropRectView.verticalRatio) );
}

- (void)zoomToCropRect:(CGRect)toRect toFill:(BOOL)toFill force:(BOOL)force centeringStatus:(IDPCropViewCenteringStatus)centeringStatus
{
    if (CGRectEqualToRect(self.scrollView.frame, toRect) && force != YES) {
        return;
    }
 
//    NSLog(@"1) self.scrollView.contentOffset=%@",[NSValue valueWithCGPoint:self.scrollView.contentOffset]);
    
    CGFloat width = CGRectGetWidth(toRect);
    CGFloat height = CGRectGetHeight(toRect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);

    // ズーム矩形を計算
    CGRect zoomRect = [self convertRect:toRect toView:self.zoomingView];
    zoomRect.size.width = CGRectGetWidth(cropRect) / scale;
    zoomRect.size.height = CGRectGetHeight(cropRect) / scale;
    
    // 古いcontentOffsetを記憶
    CGPoint oldContentOffset = CGPointZero;
    CGRect oldCropRect = self.scrollView.bounds;
//    NSLog(@"oldCropRect=%@",[NSValue valueWithCGRect:oldCropRect]);
//    NSLog(@"cropRect=%@",[NSValue valueWithCGRect:cropRect]);
    CGFloat widthDiff = oldCropRect.size.width - cropRect.size.width;
    CGFloat heightDiff = oldCropRect.size.height - cropRect.size.height;
    oldContentOffset = CGPointMake(self.scrollView.contentOffset.x + widthDiff * .5f, self.scrollView.contentOffset.y + heightDiff * .5f);

    // 最小スケールを計算
    if( toFill ){
//        NSLog(@"cropRect=%@",[NSValue valueWithCGRect:cropRect]);
//        NSLog(@"self.zoomingView.frame=%@",[NSValue valueWithCGRect:self.zoomingView.frame]);
        
        CGFloat zoomScale = self.scrollView.zoomScale;
        CGFloat minimumZoomScale = MAX( CGRectGetWidth(cropRect) / (CGRectGetWidth(self.zoomingView.frame) / zoomScale)
                                       ,CGRectGetHeight(cropRect) / (CGRectGetHeight(self.zoomingView.frame) / zoomScale) );
        self.scrollView.minimumZoomScale = minimumZoomScale;
    }
    
//    NSLog(@"2) self.scrollView.contentOffset=%@",[NSValue valueWithCGPoint:self.scrollView.contentOffset]);

    
    dispatch_block_t block = ^{
//        NSLog(@"1) self.scrollView.bounds=%@",[NSValue valueWithCGRect:self.scrollView.bounds]);
        self.scrollView.bounds = cropRect;
//        NSLog(@"2) self.scrollView.bounds=%@",[NSValue valueWithCGRect:self.scrollView.bounds]);

        NSNumber* oldZoomScale = nil;
        
        if( force != YES ){
            oldZoomScale =  @(self.scrollView.zoomScale);
            [self.scrollView zoomToRect:zoomRect animated:NO];
        }
//        NSLog(@"3) self.scrollView.contentOffset=%@",[NSValue valueWithCGPoint:self.scrollView.contentOffset]);
        
        
        [self layoutCropRectViewWithCropRect:cropRect];
        if( toFill ){
//            NSLog(@"self.scrollView.minimumZoomScal=%@",@(self.scrollView.minimumZoomScale));
//            NSLog(@"oldZoomScale=%@",oldZoomScale);
            
            CGFloat zoomScale = ( oldZoomScale != nil && [oldZoomScale floatValue] > self.scrollView.minimumZoomScale ) ? [oldZoomScale floatValue] : self.scrollView.minimumZoomScale;
            
            self.scrollView.zoomScale = zoomScale;
//            NSLog(@"4) self.scrollView.contentOffset=%@",[NSValue valueWithCGPoint:self.scrollView.contentOffset]);

            
            CGPoint contentOffset = oldContentOffset;
            if( centeringStatus & IDPCropViewCenteringStatusBoth ){
                CGPoint centeringPosition = [self generateCenteringPosition];
                
                if( centeringStatus & IDPCropViewCenteringStatusHorizontal ){
                    contentOffset.x = centeringPosition.x;
                }

                if( centeringStatus & IDPCropViewCenteringStatusVertical ){
                    contentOffset.y = centeringPosition.y;
                }
            }
            
            [self.scrollView setContentOffset:contentOffset animated:NO];
//            NSLog(@"5) self.scrollView.contentOffset=%@",[NSValue valueWithCGPoint:self.scrollView.contentOffset]);
            
            if( (~centeringStatus) & IDPCropViewCenteringStatusBoth ){
                // 中央よせ以外は座標がずれている可能性があるので調整
                CGRect maskRect = [self convertRect:cropRect toView:self.imageView];
                CGRect zooomViewRect = self.imageView.frame;
                
//                NSLog(@"maskRect=%@",[NSValue valueWithCGRect:maskRect]);
//                NSLog(@"zooomViewRect=%@",[NSValue valueWithCGRect:zooomViewRect]);
                
                if( maskRect.origin.x < .0){
                    contentOffset.x -= maskRect.origin.x * self.scrollView.zoomScale;
                }else if( CGRectGetMaxX(maskRect) > CGRectGetMaxX(zooomViewRect) ){
                    contentOffset.x -= (CGRectGetMaxX(maskRect) - CGRectGetMaxX(zooomViewRect) ) * self.scrollView.zoomScale;
                }
                
                if( maskRect.origin.y < .0){
                    contentOffset.y -= maskRect.origin.y * self.scrollView.zoomScale;
                }else if( CGRectGetMaxY(maskRect) > CGRectGetMaxY(zooomViewRect) ){
                    contentOffset.y -= (CGRectGetMaxY(maskRect) - CGRectGetMaxY(zooomViewRect) ) * self.scrollView.zoomScale;
                }
                [self.scrollView setContentOffset:contentOffset animated:NO];
            }
        }
    };
    
    if( force != YES && !(centeringStatus & IDPCropViewCenteringStatusNoAnimation) ){
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:block completion:^(BOOL finished) {
                             
                         }];
    }else{
        block();
    }
}

#pragma mark -

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    CGFloat rotation = gestureRecognizer.rotation;
    
    CGAffineTransform transform = CGAffineTransformRotate(self.imageView.transform, rotation);
    self.imageView.transform = transform;
    gestureRecognizer.rotation = 0.0f;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.cropRectView.showsGridMinor = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.cropRectView.showsGridMinor = NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint contentOffset = scrollView.contentOffset    ;
    *targetContentOffset = contentOffset;
}

@end
