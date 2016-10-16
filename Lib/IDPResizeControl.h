//
//  IDPResizeControl.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol IDPResizeControlViewDelegate;

@interface IDPResizeControl : UIView

@property (nonatomic, weak) id<IDPResizeControlViewDelegate> delegate;
@property (nonatomic, readonly) CGPoint translation;

@end

@protocol IDPResizeControlViewDelegate <NSObject>

- (void)resizeControlViewDidBeginResizing:(IDPResizeControl *)resizeControlView;
- (void)resizeControlViewDidResize:(IDPResizeControl *)resizeControlView;
- (void)resizeControlViewDidEndResizing:(IDPResizeControl *)resizeControlView;

@end
