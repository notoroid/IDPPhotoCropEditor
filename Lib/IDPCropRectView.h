//
//  IDPCropRectView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IDPCropRectViewLockDirection )
{
     IDPCropRectViewLockDirectionNeutoral
    ,IDPCropRectViewLockDirectionHorizontal
    ,IDPCropRectViewLockDirectionVertical
};


@class IDPResizeControl;

@interface IDPCropRectView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL showsGridMajor;
@property (nonatomic) BOOL showsGridMinor;

@property (nonatomic) BOOL keepingAspectRatio;

@property (nonatomic) IDPResizeControl *rotateControlView;
@property (nonatomic) CGFloat verticalRatio;
@property (nonatomic) CGFloat horizontalRatio;
@property (nonatomic) IDPCropRectViewLockDirection controlLockDirection;
@property (nonatomic) CGFloat cropLockMargine;

@end

@protocol IDPCropRectViewDelegate <NSObject>

- (CGRect)cropRectView:(IDPCropRectView *)cropRectView rectForEditingInitialRect:(CGRect)initialRect;
- (void)cropRectView:(IDPCropRectView *)cropRectView didChangedRotationControlRect:(CGRect)rotationControlRect;

- (void)cropRectViewDidBeginEditing:(IDPCropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(IDPCropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(IDPCropRectView *)cropRectView;

@end

