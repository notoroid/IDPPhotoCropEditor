//
//  IDPCropViewController.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "IDPCropViewController.h"
#import "IDPCropView.h"
#import "IDPCropFigureRenderer.h"
#import "IDPTrackerView.h"

static UIImage *s_imageRatio3to4Button = nil;
static UIImage *s_imageRatio4to3Button = nil;
static UIImage *s_imageSquareButton = nil;

#define COPR_VIEW_ALERT_NETWOTK_FAILURE_TAG 100

CGFloat degreesToRadians(CGFloat degrees);
CGFloat degreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

CGFloat radiansToDegrees(CGFloat radians);
CGFloat radiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

@interface IDPCropViewController () <IDPCropViewDelegate>
{
    BOOL _resizingView;
    UIView* _compatibilityView;
    IDPCropViewEditMode _editMode;
    NSValue* _edgeInsets;
    IDPCropViewFrameType _frameType;
    UIColor *_overlayColor;
}

@property (nonatomic) UIImageView* guideView; // ガイド枠表示用
@property (nonatomic) UIView* trackView;

@property (retain,nonatomic) UIButton* buttonDegreeReset;
@property (retain,nonatomic) UILabel* labelDegree;
@property (retain,nonatomic) UIImageView* backgroundView;

@property (nonatomic) IDPCropView *cropView;

@end

@implementation IDPCropViewController

- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
    }else{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.view.frame = CGRectMake(.0f,.0f,screenSize.width,screenSize.height);
    }
    
    CGRect rect = contentView.bounds;
//    UIImageView* backgroundImageView = [[UIImageView alloc] init];
//    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    backgroundImageView.frame = rect;
//    backgroundImageView.image = [UIImage imageNamed:@"PhotocropBackground.png"];
//    backgroundImageView.contentMode = UIViewContentModeTop;
//    [contentView addSubview:backgroundImageView];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:rect];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
// TODO:
    backgroundView.backgroundColor = _backgroundColor != nil ? _backgroundColor : [UIColor blackColor];
    [contentView addSubview:backgroundView];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
    }else{
        const CGFloat statusBarHeight = (_delegate != nil && [_delegate respondsToSelector:@selector(cropViewControllerStatusBarHeight:)] ) ? [_delegate cropViewControllerStatusBarHeight:self] : 20.0f;
        const CGFloat navigationBarHeight = self.navigationController.navigationBarHidden ? 0 : 44;
        const CGFloat toolBarHeight = _toolBarHidden ? .0f : 44.0f;
        rect = CGRectMake(.0f, statusBarHeight + navigationBarHeight,rect.size.width ,rect.size.height - statusBarHeight - navigationBarHeight - toolBarHeight);
    }

    CGRect guideRect = rect;
    if( _edgeInsets != nil ){
        UIEdgeInsets edgeInsets = [_edgeInsets UIEdgeInsetsValue];
        CGFloat edgeHorizontalDiff = edgeInsets.left - edgeInsets.right;
        CGFloat edgeVerticalDiff = edgeInsets.top - edgeInsets.bottom;
//        rect = CGRectOffset(rect, edgeHorizontalDiff, edgeVerticalDiff);
        rect.size = CGSizeMake(rect.size.width + edgeHorizontalDiff,rect.size.height + edgeVerticalDiff);
    }
    
    self.cropView = [[IDPCropView alloc] initWithFrame:rect];
    self.cropView.delegate = self;
    self.editMode = _editMode;
    if( _edgeInsets != nil ){
        UIEdgeInsets edgeInsets = [_edgeInsets UIEdgeInsetsValue];
        CGFloat minHorizontalEdge = MIN(edgeInsets.left,edgeInsets.right);
        CGFloat minVerticalEdge = MIN(edgeInsets.top,edgeInsets.bottom);
        
        self.cropView.edgeInsets = UIEdgeInsetsMake(minVerticalEdge, minHorizontalEdge, minVerticalEdge, minHorizontalEdge);
    }
    self.cropView.overlayColor = _overlayColor;
    [contentView addSubview:self.cropView];
    
    _guideView = [[UIImageView alloc] initWithFrame:guideRect];
    [contentView addSubview:_guideView];
        // ガイド線を追加
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = _cancelButton != nil ? _cancelButton : [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = _doneButton != nil ? _doneButton : [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];
    
    [self updateEditMode];
        // エディットモード反映
    
    self.navigationController.toolbarHidden = _toolBarHidden;
        // ツールバーの非表示を設定
    
    self.cropView.image = self.image;
}

- (void) updateEditMode
{
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    fixedSpace.width = 5.0f;

    if( _editMode == IDPCropViewEditModeCrop ){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            s_imageRatio3to4Button = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeMonoRatio3to4Button options:nil];

            s_imageSquareButton = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeMonoSquareButton options:nil];
            
            s_imageRatio4to3Button = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeMonoRatio4to3Button options:nil];
        });
        
        UIBarButtonItem *button3to4 = [[UIBarButtonItem alloc] initWithImage:s_imageRatio3to4Button style:UIBarButtonItemStylePlain target:self action:@selector(fired3To4:)];
        
        UIBarButtonItem *buttonSquare = [[UIBarButtonItem alloc] initWithImage:s_imageSquareButton style:UIBarButtonItemStylePlain target:self action:@selector(firedSquare:)];

        UIBarButtonItem *button4to3 = [[UIBarButtonItem alloc] initWithImage:s_imageRatio4to3Button style:UIBarButtonItemStylePlain target:self action:@selector(fired4To3:)];
        
        self.toolbarItems = @[flexibleSpace,button3to4,buttonSquare,button4to3,flexibleSpace];
    }else{
        self.toolbarItems = [self degreeToolbarItemsWithAppendButton:nil style:IDPDegreeAdjustmentToolbarStyleDefault];
    }
}

- (NSArray *) degreeToolbarItemsWithAppendButton:(UIBarButtonItem *)appendButton style:(IDPDegreeAdjustmentToolbarStyle)style
{
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    
    UIImage *rorate90degreeImage = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeMonoRotate90degreeButton options:nil];
    UIBarButtonItem* rorate90degreeButtotn = [[UIBarButtonItem alloc] initWithImage:rorate90degreeImage style:UIBarButtonItemStylePlain target:self action:@selector(firedRotate90degree:)];
    
    // 角度情報表示用UIを作成する
    UIView* viewDegreeInfomation = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, 71.0f, 31.0f)];
    viewDegreeInfomation.backgroundColor = /*[UIColor redColor]*/ [UIColor clearColor];
    
    UIImage* imageDegreeInformationBackground = [IDPCropFigureRenderer createImageWithFigureType:style == IDPDegreeAdjustmentToolbarStyleDefault ? IDPCropFigureRendererTypeDegreeInformationBackground : IDPCropFigureRendererTypeDarkDegreeInformationBackground options:nil];
    [imageDegreeInformationBackground imageWithAlignmentRectInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f)];
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, 71.0f, 31.0f)];
    //    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, .0f, 71.0f - 20.0f, 31.0f)];
    self.backgroundView.image = imageDegreeInformationBackground;
    [viewDegreeInfomation addSubview:self.backgroundView];
    
    self.labelDegree = [[UILabel alloc] initWithFrame:CGRectMake(28.0f, .0f, 35.0f, 31.0f)];
    //    self.labelDegree = [[UILabel alloc] initWithFrame:CGRectMake(28.0f, .0f, 35.0f, 31.0f)];
    self.labelDegree.font = [UIFont boldSystemFontOfSize:14.0f];
    self.labelDegree.textColor = style == IDPDegreeAdjustmentToolbarStyleDefault ? [UIColor blackColor] : [UIColor whiteColor];
    
    self.labelDegree.textAlignment = NSTextAlignmentCenter;
    self.labelDegree.backgroundColor = [UIColor clearColor];
    
    [viewDegreeInfomation addSubview:self.labelDegree];
    
    self.buttonDegreeReset = [[UIButton alloc] initWithFrame:CGRectMake(50.0f, 5.0f, 21, 21)];
    [self.buttonDegreeReset setImage:[IDPCropFigureRenderer createImageWithFigureType:style == IDPDegreeAdjustmentToolbarStyleDefault ? IDPCropFigureRendererTypeResetDegree : IDPCropFigureRendererTypeDarkResetDegree options:nil] forState:UIControlStateNormal];
    [viewDegreeInfomation addSubview:self.buttonDegreeReset];
    [self.buttonDegreeReset addTarget:self action:@selector(firedResetRotate:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateRotationInformation:self.cropView.rotationAngle];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewDegreeInfomation];
    
    NSArray* degreeToolbarItems = appendButton != nil ? @[fixedSpace,rorate90degreeButtotn,flexibleSpace,barButtonItem,flexibleSpace,appendButton] : @[fixedSpace,rorate90degreeButtotn,flexibleSpace,barButtonItem,flexibleSpace];
    
    
    return degreeToolbarItems;
}

- (void) fired3To4:(id)sender
{
//    NSLog(@"cropData=%@",self.cropData );
    
    IDPCropViewCenteringStatus centeringStatus = [self.cropView centeringStatus];
    [self setCropAspectRatio:3.0f / 4.0f centeringStatus:centeringStatus];
}

- (void) firedSquare:(id)sender
{
//    NSLog(@"cropData=%@",self.cropData );
    
    IDPCropViewCenteringStatus centeringStatus = [self.cropView centeringStatus];
    [self setCropAspectRatio:1.0f / 1.0f centeringStatus:centeringStatus];
}

- (void) fired4To3:(id)sender
{
//    NSLog(@"cropData=%@",self.cropData );
    
    IDPCropViewCenteringStatus centeringStatus = [self.cropView centeringStatus];
    [self setCropAspectRatio:4.0f / 3.0f centeringStatus:centeringStatus];
    
}

- (void) updateRotationInformation:(CGFloat)rotation
{
    double degree = radiansToDegrees( self.cropView.rotationAngle );
    if( degree < .0f )
        degree += 360.0f;
    
    self.labelDegree.text = [NSString stringWithFormat:@"%0.1f",degree];
    if( degree == 0 ){
        self.backgroundView.frame = CGRectMake(15.0f, .0f, 71.0f - 20.0f, 31.0f);
        self.labelDegree.frame = CGRectMake(23.0f, .0f, 35.0f, 31.0f);
        self.labelDegree.textAlignment = NSTextAlignmentCenter;
        self.buttonDegreeReset.hidden = YES;
    }else{
        
        self.backgroundView.frame = CGRectMake(5.0f, .0f, 71.0f, 31.0f);
        self.labelDegree.frame = CGRectMake(5.0f, .0f, 44.0f, 31.0f);
        self.labelDegree.textAlignment = NSTextAlignmentRight;
        self.buttonDegreeReset.hidden = NO;
    }
    
}

- (void) viewWillLayoutSubviews
{
    if( _guideView != nil && _guideView.image == nil ){
        _guideView.frame =  self.cropView.frame;
        
        _guideView.autoresizingMask = self.view.autoresizingMask;
        _guideView.image = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeCropArea
                                                                    options:@{IDP_CROP_CROPAREA_FRAME_NAME:[NSValue valueWithCGRect:CGRectMake(.0f,.0f,_guideView.frame.size.width,_guideView.frame.size.height)],IDP_CROP_CROPAREA_ASPECT_RAOTO_NAME:@(self.cropAspectRatio),IDP_CROP_CROPAREA_ASPECT_EDGE_INSETS_NAME:[NSValue valueWithUIEdgeInsets:self.cropView.edgeInsets],IDP_CROP_CROPAREA_FRAME_TYPE:@(_frameType)}
                            ];
        _guideView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.cropAspectRatio != 0) {
        [self setCropAspectRatio:self.cropAspectRatio centeringStatus:IDPCropViewCenteringStatusBoth | IDPCropViewCenteringStatusNoAnimation];
    }
    if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
        self.cropRect = self.cropRect;
    }

    self.keepingCropAspectRatio = self.keepingCropAspectRatio;
    
    // ここでmetadetaを適用する
    if( self.cropData != nil )
        self.cropView.cropData = self.cropData;
    
    [self updateRotationInformation:self.cropView.rotationAngle];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.cropView.image = image;
}

- (void)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)]) {
        [self.delegate cropViewControllerDidCancel:self];
    }
}

- (UIImage *) createCroppedImage
{
    UIImage *croppedImage = self.cropView.croppedImage;
    return croppedImage;
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:cropData:)]) {
        @autoreleasepool {
            NSDictionary* cropData = self.cropView.cropData;
            UIImage *croppedImage = self.cropView.croppedImage;
            [self.delegate cropViewController:self didFinishCroppingImage:croppedImage cropData:cropData];
        }
    }
}

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio;
}

- (IDPCropViewEditMode) editMode
{
    return _editMode;
}

- (void) setEditMode:(IDPCropViewEditMode)editMode
{
    _editMode = editMode;
    [self updateEditMode];
    
    self.cropView.editMode = _editMode;
}

- (UIEdgeInsets) edgeInsets
{
    return _edgeInsets != nil ? [_edgeInsets UIEdgeInsetsValue] : UIEdgeInsetsMake(IDP_CROP_VERTICAL_MARGINE,IDP_CROP_HORIZONTAL_MARGINE,IDP_CROP_VERTICAL_MARGINE,IDP_CROP_HORIZONTAL_MARGINE);
}

- (void) setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = [NSValue valueWithUIEdgeInsets:edgeInsets];
//    self.cropView.edgeInsets = edgeInsets;
}

- (IDPCropViewFrameType) frameType
{
    return _frameType;
}

- (void) setFrameType:(IDPCropViewFrameType)frameType
{
    [self setFrameType:frameType animated:YES];
}

- (void) setFrameType:(IDPCropViewFrameType)frameType animated:(BOOL)animated
{
    if( _frameType != frameType){
        _frameType = frameType;
        
        if( _guideView != nil ){
            // オプション情報を定義
            NSDictionary *options = @{IDP_CROP_CROPAREA_FRAME_NAME:[NSValue valueWithCGRect:CGRectMake(.0f,.0f,_guideView.frame.size.width,_guideView.frame.size.height)],IDP_CROP_CROPAREA_ASPECT_RAOTO_NAME:@(self.cropAspectRatio),IDP_CROP_CROPAREA_ASPECT_EDGE_INSETS_NAME:[NSValue valueWithUIEdgeInsets:self.cropView.edgeInsets],IDP_CROP_CROPAREA_FRAME_TYPE:@(_frameType)};
            
            if( animated ){
                UIImageView* guideView = [[UIImageView alloc] initWithFrame:_guideView.frame];
                guideView.autoresizingMask = _guideView.autoresizingMask;
                guideView.image = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeCropArea options:options ];
                guideView.contentMode = UIViewContentModeScaleAspectFill;
                guideView.alpha = .0f;
                [_guideView.superview insertSubview:guideView aboveSubview:_guideView];
                
                [UIView animateWithDuration:.25f delay:.0f options:0 animations:^{
                    _guideView.alpha = .0f;
                    guideView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [_guideView removeFromSuperview];
                    _guideView = guideView;
                        // 新しいguideView として追加
                }];
            }else{
                _guideView.image = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeCropArea options:options ];
            }
            
        }
    }
}

- (UIColor *) overlayColor
{
    return _overlayColor;
}

- (void) setOverlayColor:(UIColor *)overlayColor
{
    _overlayColor = overlayColor;
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio
{
    [self setCropAspectRatio:cropAspectRatio centeringStatus:IDPCropViewCenteringStatusBoth];
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio centeringStatus:(IDPCropViewCenteringStatus)centeringStatus
{
    BOOL resizeGudeView = _cropAspectRatio != cropAspectRatio ? (_cropAspectRatio != .0f ? YES : NO) : NO;
    
    _cropAspectRatio = cropAspectRatio;
    
    [self.cropView setCropAspectRatio:self.cropAspectRatio centeringStatus:centeringStatus];
    
    if( resizeGudeView ){
        [UIView animateWithDuration:.25f animations:^{
            _guideView.frame =  self.cropView.frame;
        } completion:^(BOOL finished) {
            _guideView.autoresizingMask = self.view.autoresizingMask;
            _guideView.image = [IDPCropFigureRenderer createImageWithFigureType:IDPCropFigureRendererTypeCropArea
                                                                   options:@{IDP_CROP_CROPAREA_FRAME_NAME:[NSValue valueWithCGRect:CGRectMake(.0f,.0f,_guideView.frame.size.width,_guideView.frame.size.height)],IDP_CROP_CROPAREA_ASPECT_RAOTO_NAME:@(self.cropAspectRatio),IDP_CROP_CROPAREA_ASPECT_EDGE_INSETS_NAME:[NSValue valueWithUIEdgeInsets:self.cropView.edgeInsets],IDP_CROP_CROPAREA_FRAME_TYPE:@(_frameType)}
                                ];
            _guideView.contentMode = UIViewContentModeScaleAspectFill;
        }];
    }
}

- (IDPCropViewCenteringStatus) centeringStatus
{
    return [self.cropView centeringStatus];
}

- (CGFloat) rotationAngle
{
    return self.cropView.rotationAngle;
}

- (void) setRotationAngle:(CGFloat)rotationAngle
{
    self.cropView.rotationAngle = rotationAngle;
    [self updateRotationInformation:rotationAngle];
}

- (CGFloat) baseDegree
{
    return self.cropView.baseDegree;
}

- (void) resetRotate
{
    self.cropView.baseDegree = 0;
    [self.cropView setRotationAngle:degreesToRadians(self.cropView.baseDegree) withNormalizeZoomByRotate:YES];
    // 回転及び横倒し指定を修正
    
    self.cropView.rotationAngle = degreesToRadians(0);
    
    [self.cropView resetRotationControl];
    
    [self updateRotationInformation:self.cropView.rotationAngle];
}

- (void) rotate90degree
{
    // 現在のラジアン値を取得
    double degree = radiansToDegrees( self.cropView.rotationAngle );
    degree += 90;
    
    self.cropView.baseDegree += 90.0;
    
    [self.cropView setRotationAngle:degreesToRadians(degree) withNormalizeZoomByRotate:YES];
    // 回転及び横倒し指定を修正
    
    if( self.cropView.baseDegree >= 360.0f ){
        self.cropView.baseDegree -= 360.0f;
    }
    
    [self updateRotationInformation:self.cropView.rotationAngle];
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    
    CGRect cropViewCropRect = self.cropView.cropRect;
    cropViewCropRect.origin.x += cropRect.origin.x;
    cropViewCropRect.origin.y += cropRect.origin.y;
    
    CGSize size = CGSizeMake(fminf(CGRectGetMaxX(cropViewCropRect) - CGRectGetMinX(cropViewCropRect), CGRectGetWidth(cropRect)),
                             fminf(CGRectGetMaxY(cropViewCropRect) - CGRectGetMinY(cropViewCropRect), CGRectGetHeight(cropRect)));
    cropViewCropRect.size = size;
    self.cropView.cropRect = cropViewCropRect;
}

- (void) firedResetRotate:(id)sender
{
    [self resetRotate];
}

- (void)firedRotate90degree:(id)sender
{
    [self rotate90degree];
}

#pragma mark - IDPCropView delegate method(s)

- (void)cropView:(IDPCropView *)cropRectView disUpdateRotation:(CGFloat)rotation
{
    [self updateRotationInformation:rotation];
}

- (void)cropView:(IDPCropView *)cropRectView didChangedRotationControlRect:(CGRect)rotationControlRect
{
//    NSLog(@"rotationControlRect=%@",[NSValue valueWithCGRect:rotationControlRect]);
    
    CGRect convertRect = [self.view convertRect:rotationControlRect fromView:cropRectView];
    
    if( self.trackView == nil ){
        self.trackView = [[IDPTrackerView alloc] initWithFrame:convertRect];
        self.trackView.userInteractionEnabled = NO;
        self.trackView.opaque = NO;
        [self.view addSubview:self.trackView];
        [self.view bringSubviewToFront:self.trackView];
    }else{
        self.trackView.frame = convertRect;
    }
    
//    NSLog(@"self.cropView.isFill=%@",self.cropView.isFill ? @"YES" : @"NO" );
    
}


@end
