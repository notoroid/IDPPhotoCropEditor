//
//  IDPCropRectView.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "IDPCropRectView.h"
#import "IDPResizeControl.h"

@interface IDPCropRectView () <IDPResizeControlViewDelegate>

@property (nonatomic) IDPResizeControl *topLeftCornerView;
@property (nonatomic) IDPResizeControl *topRightCornerView;
@property (nonatomic) IDPResizeControl *bottomLeftCornerView;
@property (nonatomic) IDPResizeControl *bottomRightCornerView;
@property (nonatomic) IDPResizeControl *topEdgeView;
@property (nonatomic) IDPResizeControl *leftEdgeView;
@property (nonatomic) IDPResizeControl *bottomEdgeView;
@property (nonatomic) IDPResizeControl *rightEdgeView;

@property (nonatomic) CGRect initialRect;
@property (nonatomic) CGFloat fixedAspectRatio;

@end

@implementation IDPCropRectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        self.contentMode = UIViewContentModeRedraw;
        
        self.showsGridMajor = YES;
        self.showsGridMinor = NO;
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -2.0f, -2.0f)];
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        imageView.image = [[UIImage imageNamed:@"PEPhotoCropEditor.bundle/PEPhotoCropEditorBorder"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f)];
//        [self addSubview:imageView];
        
//        self.topLeftCornerView = [[IDPResizeControl alloc] init];
//        self.topLeftCornerView.delegate = self;
//        [self addSubview:self.topLeftCornerView];
//        
//        self.topRightCornerView = [[IDPResizeControl alloc] init];
//        self.topRightCornerView.delegate = self;
//        [self addSubview:self.topRightCornerView];
//        
//        self.bottomLeftCornerView = [[IDPResizeControl alloc] init];
//        self.bottomLeftCornerView.delegate = self;
//        [self addSubview:self.bottomLeftCornerView];
//        
//        self.bottomRightCornerView = [[IDPResizeControl alloc] init];
//        self.bottomRightCornerView.delegate = self;
//        [self addSubview:self.bottomRightCornerView];
//        
//        self.topEdgeView = [[IDPResizeControl alloc] init];
//        self.topEdgeView.delegate = self;
//        [self addSubview:self.topEdgeView];
//        
//        self.leftEdgeView = [[IDPResizeControl alloc] init];
//        self.leftEdgeView.delegate = self;
//        [self addSubview:self.leftEdgeView];
//        
//        self.bottomEdgeView = [[IDPResizeControl alloc] init];
//        self.bottomEdgeView.delegate = self;
//        [self addSubview:self.bottomEdgeView];
//        
//        self.rightEdgeView = [[IDPResizeControl alloc] init];
//        self.rightEdgeView.delegate = self;
//        [self addSubview:self.rightEdgeView];

        self.verticalRatio = 1.0f;
        self.horizontalRatio = 1.0f;
        
        self.rotateControlView = [[IDPResizeControl alloc] init];
        self.rotateControlView.delegate = self;
        [self addSubview:self.rotateControlView];
        
    }
    
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[IDPResizeControl class]]) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return subview;
            }
        }
    }
    
    return nil;
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    CGFloat width = CGRectGetWidth(self.bounds);
//    CGFloat height = CGRectGetHeight(self.bounds);
//    
//    for (NSInteger i = 0; i < 3; i++) {
//        if (self.showsGridMinor) {
//            for (NSInteger j = 1; j < 3; j++) {
//                [[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.3f] set];
//                
//                UIRectFill(CGRectMake(roundf(width / 3 / 3 * j + width / 3 * i), 0.0f, 1.0f, roundf(height)));
//                UIRectFill(CGRectMake(0.0f, roundf(height / 3 / 3 * j + height / 3 * i), roundf(width), 1.0f));
//            }
//        }
//        
//        if (self.showsGridMajor) {
//            if (i > 0) {
//                [[UIColor whiteColor] set];
//                
//                UIRectFill(CGRectMake(roundf(width / 3 * i), 0.0f, 1.0f, roundf(height)));
//                UIRectFill(CGRectMake(0.0f, roundf(height / 3 * i), roundf(width), 1.0f));
//            }
//        }
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetWidth(self.topLeftCornerView.bounds) / -2, CGRectGetHeight(self.topLeftCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetHeight(self.topRightCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetWidth(self.bottomLeftCornerView.bounds) / -2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.frame) / -2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetWidth(self.leftEdgeView.frame) / -2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
    
    CGRect rotateControlViewFrame = CGRectMake( CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rotateControlView.bounds) / 2
                                               ,CGRectGetHeight(self.bounds) - CGRectGetHeight(self.rotateControlView.bounds) / 2
                                               ,self.rotateControlView.bounds.size.width
                                               ,self.rotateControlView.bounds.size.height );
    self.rotateControlView.frame = rotateControlViewFrame;
//    NSLog(@"self.rotateControlView.frame=%@",[NSValue valueWithCGRect:self.rotateControlView.frame ]);
    
    [self.delegate cropRectView:self didChangedRotationControlRect:self.rotateControlView.frame];

}

#pragma mark -

- (void)setShowsGridMajor:(BOOL)showsGridMajor
{
    _showsGridMajor = showsGridMajor;
    [self setNeedsDisplay];
}

- (void)setShowsGridMinor:(BOOL)showsGridMinor
{
    _showsGridMinor = showsGridMinor;
    [self setNeedsDisplay];
}

- (void)setKeepingAspectRatio:(BOOL)keepingAspectRatio
{
    _keepingAspectRatio = keepingAspectRatio;
    
    if (self.keepingAspectRatio) {
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        self.fixedAspectRatio = fminf(width / height, height / width);
    }
}

#pragma mark -

- (void)resizeControlViewDidBeginResizing:(IDPResizeControl *)resizeConrolView
{
    self.initialRect = _delegate != nil ? [_delegate cropRectView:self rectForEditingInitialRect:self.frame] : self.frame;
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    NSLog(@"self.frame=%@",[NSValue valueWithCGRect:self.frame] );
    
    if ([self.delegate respondsToSelector:@selector(cropRectViewDidBeginEditing:)]) {
        [self.delegate cropRectViewDidBeginEditing:self];
    }
}

- (void)resizeControlViewDidResize:(IDPResizeControl *)resizeConrolView
{
    self.frame = [self cropRectMakeWithResizeControlView:resizeConrolView];
        
    if ([self.delegate respondsToSelector:@selector(cropRectViewEditingChanged:)]) {
        [self.delegate cropRectViewEditingChanged:self];
    }
}

- (void)resizeControlViewDidEndResizing:(IDPResizeControl *)resizeConrolView
{
    if( self.controlLockDirection == IDPCropRectViewLockDirectionNeutoral ){
        self.verticalRatio = 1.0f;
        self.horizontalRatio = 1.0f;
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.initialRect.size.width, self.initialRect.size.height);

        self.rotateControlView.frame = CGRectMake( CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rotateControlView.bounds) / 2
                                                  ,CGRectGetHeight(self.bounds) - CGRectGetHeight(self.rotateControlView.bounds) / 2
                                                  ,self.rotateControlView.bounds.size.width
                                                  ,self.rotateControlView.bounds.size.height );
        [self.delegate cropRectView:self didChangedRotationControlRect:self.rotateControlView.frame];
    }
    
    if ([self.delegate respondsToSelector:@selector(cropRectViewDidEndEditing:)]) {
        [self.delegate cropRectViewDidEndEditing:self];
    }
}


- (CGFloat) cropLockMargine
{
    return 2.0;
}

- (CGRect)cropRectMakeWithResizeControlView:(IDPResizeControl *)resizeControlView
{
    CGRect rect = self.frame;
    
    if (resizeControlView == self.topEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            rect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
        }
    } else if (resizeControlView == self.leftEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
        
        if (self.keepingAspectRatio) {
            rect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
        }
    } else if (resizeControlView == self.bottomEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            rect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
        }
    } else if (resizeControlView == self.rightEdgeView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
        
        if (self.keepingAspectRatio) {
            rect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
        }
    } else if (resizeControlView == self.topLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            CGRect constrainedRect;
            if (fabs(resizeControlView.translation.x) < fabs(resizeControlView.translation.y)) {
                constrainedRect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
            } else {
                constrainedRect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
            }
            constrainedRect.origin.x -= CGRectGetWidth(constrainedRect) - CGRectGetWidth(rect);
            constrainedRect.origin.y -= CGRectGetHeight(constrainedRect) - CGRectGetHeight(rect);
            rect = constrainedRect;
        }
    } else if (resizeControlView == self.topRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            if (fabs(resizeControlView.translation.x) < fabs(resizeControlView.translation.y)) {
                rect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
            } else {
                rect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
            }
        }
    } else if (resizeControlView == self.bottomLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            CGRect constrainedRect;
            if (fabs(resizeControlView.translation.x) < fabs(resizeControlView.translation.y)) {
                constrainedRect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
            } else {
                constrainedRect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
            }
            constrainedRect.origin.x -= CGRectGetWidth(constrainedRect) - CGRectGetWidth(rect);
            rect = constrainedRect;
        }
    } else if (resizeControlView == self.bottomRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
        if (self.keepingAspectRatio) {
            if (fabs(resizeControlView.translation.x) < fabs(resizeControlView.translation.y)) {
                rect = [self constrainedRectWithRectBasisOfHeight:rect aspectRatio:self.fixedAspectRatio];
            } else {
                rect = [self constrainedRectWithRectBasisOfWidth:rect aspectRatio:self.fixedAspectRatio];
            }
        }
    } else if (resizeControlView == self.rotateControlView ) {
        
#define IDP_CROP_LOCK_MARGINE (-self.cropLockMargine)
        CGFloat unlockLimit = -CGRectGetWidth(self.rotateControlView.bounds) / 2;
        
        // 方向を計算するブロックス関数を用意
        CGRect (^rectByLockDirection)(IDPCropRectViewLockDirection controlLockDirection,CGPoint translation) = ^CGRect(IDPCropRectViewLockDirection controlLockDirection,CGPoint translation)
        {
            CGRect rect = CGRectZero;
            switch (controlLockDirection) {
                case IDPCropRectViewLockDirectionNeutoral:
                    rect = CGRectMake(CGRectGetMinX(self.initialRect),
                                      CGRectGetMinY(self.initialRect),
                                      MIN(CGRectGetWidth(self.initialRect),CGRectGetWidth(self.initialRect) * self.horizontalRatio + resizeControlView.translation.x),
                                      MIN(CGRectGetHeight(self.initialRect),CGRectGetHeight(self.initialRect) * self.verticalRatio + resizeControlView.translation.y));
                    break;
                case IDPCropRectViewLockDirectionHorizontal:
                    rect = CGRectMake(CGRectGetMinX(self.initialRect),
                                      CGRectGetMinY(self.initialRect),
                                      MIN(CGRectGetWidth(self.initialRect),CGRectGetWidth(self.initialRect) * self.horizontalRatio + resizeControlView.translation.x),
                                      CGRectGetHeight(self.initialRect));
                    
//                    NSLog(@"rect=%@",[NSValue valueWithCGRect:rect]);
                    
                    break;
                case IDPCropRectViewLockDirectionVertical:
                    rect = CGRectMake(CGRectGetMinX(self.initialRect),
                                      CGRectGetMinY(self.initialRect),
                                      CGRectGetWidth(self.initialRect),
                                      MIN(CGRectGetHeight(self.initialRect),CGRectGetHeight(self.initialRect) * self.verticalRatio + resizeControlView.translation.y));
                    break;
                default:
                    break;
            }
            return rect;
        };
        
        CGRect rectTest = rectByLockDirection( self.controlLockDirection , resizeControlView.translation );
        
        CGFloat widthDiff = CGRectGetWidth(rectTest) - CGRectGetWidth(self.initialRect);
        CGFloat heightDiff = CGRectGetHeight(rectTest) - CGRectGetHeight(self.initialRect);

//        NSLog(@"widthDiff=%f,heightDiff=%f",widthDiff,heightDiff);
        
        if( self.controlLockDirection == IDPCropRectViewLockDirectionHorizontal && widthDiff > IDP_CROP_LOCK_MARGINE && heightDiff > unlockLimit ){
            self.controlLockDirection = IDPCropRectViewLockDirectionNeutoral;
        }else if( self.controlLockDirection == IDPCropRectViewLockDirectionVertical && heightDiff > IDP_CROP_LOCK_MARGINE && widthDiff > unlockLimit ){
            self.controlLockDirection = IDPCropRectViewLockDirectionNeutoral;
        }else if( self.controlLockDirection == IDPCropRectViewLockDirectionNeutoral && widthDiff  < IDP_CROP_LOCK_MARGINE /*resizeControlView.translation.x < IDP_CROP_LOCK_MARGINE*/ ){
            self.controlLockDirection = IDPCropRectViewLockDirectionHorizontal;
        }else if( self.controlLockDirection == IDPCropRectViewLockDirectionNeutoral && heightDiff < IDP_CROP_LOCK_MARGINE /*resizeControlView.translation.y < IDP_CROP_LOCK_MARGINE*/ ){
            self.controlLockDirection = IDPCropRectViewLockDirectionVertical;
        }
        
        rect = rectByLockDirection( self.controlLockDirection , resizeControlView.translation );
        
    }
    
//    NSLog(@"rect=%@",[NSValue valueWithCGRect:rect] );
    if (rect.size.width < 0 ) {
        rect.size = CGSizeMake(.0f, rect.size.height);
    }
    
    if (rect.size.height < 0) {
        rect.size = CGSizeMake(rect.size.width,.0f);
    }
    
    
//    CGFloat minWidth = CGRectGetWidth(self.leftEdgeView.bounds) + CGRectGetWidth(self.rightEdgeView.bounds);
//    if (CGRectGetWidth(rect) < minWidth) {
//        rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
//        rect.size = CGSizeMake(minWidth,
//                               !self.fixedAspectRatio ? rect.size.height : rect.size.height * (minWidth / rect.size.width));
//    }
//    
//    CGFloat minHeight = CGRectGetHeight(self.topEdgeView.bounds) + CGRectGetHeight(self.bottomEdgeView.bounds);
//    if (CGRectGetHeight(rect) < minHeight) {
//        rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
//        rect.size = CGSizeMake(!self.fixedAspectRatio ? rect.size.width : rect.size.width * (minHeight / rect.size.height),
//                               minHeight);
//    }
    
    return rect;
}

- (CGRect)constrainedRectWithRectBasisOfWidth:(CGRect)rect aspectRatio:(CGFloat)aspectRatio
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    if (width < height) {
        height = width / self.fixedAspectRatio;
    } else {
        height = width * self.fixedAspectRatio;
    }
    rect.size = CGSizeMake(width, height);
    
    return rect;
}

- (CGRect)constrainedRectWithRectBasisOfHeight:(CGRect)rect aspectRatio:(CGFloat)aspectRatio
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    if (width < height) {
        width = height * self.fixedAspectRatio;
    } else {
        width = height / self.fixedAspectRatio;
    }
    rect.size = CGSizeMake(width, height);
    
    return rect;
}

@end
