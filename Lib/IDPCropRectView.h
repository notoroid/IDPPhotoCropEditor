//
//  IDPCropRectView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDPCropRectViewDelegate;

@interface IDPCropRectView : UIView

@property (nonatomic, weak) id<IDPCropRectViewDelegate> delegate;
@property (nonatomic) BOOL showsGridMajor;
@property (nonatomic) BOOL showsGridMinor;

@property (nonatomic) BOOL keepingAspectRatio;

@end

@protocol IDPCropRectViewDelegate <NSObject>

- (void)cropRectViewDidBeginEditing:(IDPCropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(IDPCropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(IDPCropRectView *)cropRectView;

@end

