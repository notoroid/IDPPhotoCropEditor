//
//  IDPCropDefinition.h
//
//  Created by 能登 要 on 2013/11/03.
//  Copyright (c) 2013 Irimasu Densan Planning. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IDPPhotoCropEditorConstants_h
#define IDPPhotoCropEditorConstants_h

#define IDP_CROP_ROTATION_NAME @"crop-rotation"
#define IDP_CROP_ZOOMED_CROP_RECT_NAME @"crop-zoomedCropRect"
#define IDP_CROP_SIDEWAYS_NAME @"crop-sideways"

#define IDP_CROP_HORIZONTAL_MARGINE 9.0f
#define IDP_CROP_VERTICAL_MARGINE 19.0f

typedef NS_ENUM(NSInteger, IDPCropViewEditMode)
{
     IDPCropViewEditModeCrop
    ,IDPCropViewEditModeAngleAdjustment
    ,IDPCropViewEditModeAngleAdjustmentNoTracker
};

typedef NS_OPTIONS(NSInteger, IDPCropViewCenteringStatus)
{
     IDPCropViewCenteringStatusHorizontal = 1
    ,IDPCropViewCenteringStatusVertical = 2
    ,IDPCropViewCenteringStatusBoth = 3
    ,IDPCropViewCenteringStatusNoAnimation = 4
};

typedef NS_OPTIONS(NSInteger, IDPDegreeAdjustmentToolbarStyle)
{
     IDPDegreeAdjustmentToolbarStyleDefault
    ,IDPDegreeAdjustmentToolbarStyleDark
};

typedef NS_ENUM(NSInteger, IDPCropViewFrameType )
{
     IDPCropViewFrameTypeDefault = 0
    ,IDPCropViewFrameTypeNoEdge
    ,IDPCropViewFrameTypeDetail
    ,IDPCropViewFrameTypeNone
};


#endif
