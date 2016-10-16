//
//  IDPTrackerView.m
//  PEPhotoCropEditor
//
//  Created by 能登 要 on 2013/10/16.
//  Copyright (c) 2013 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTrackerView.h"
#import "IDPCropFigureRenderer.h"

@implementation IDPTrackerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [IDPCropFigureRenderer renderWithFigureType:IDPCropFigureRendererTypeTracker options:nil];
}

@end
