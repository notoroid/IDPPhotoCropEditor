//
//  IDPCropFigureRenderer.h
//  
//
//  Created by Noto Kaname on 12/05/03.
//  Copyright (c) 2012年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IDP_CROP_CROPAREA_FRAME_NAME @"frame"
#define IDP_CROP_CROPAREA_ASPECT_RAOTO_NAME @"cropAspectRatio"
#define IDP_CROP_CROPAREA_ASPECT_EDGE_INSETS_NAME @"edgeInsets"
#define IDP_CROP_CROPAREA_FRAME_TYPE @"frameType"
#define IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR @"normalColor"
#define IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR @"highlightedColor"

typedef NS_ENUM(NSInteger, IDPCropFigureRendererType)
{
     IDPCropFigureRendererTypeCropArea
    ,IDPCropFigureRendererTypeTracker
    ,IDPCropFigureRendererTypeResetDegree
    ,IDPCropFigureRendererTypeDarkResetDegree
    ,IDPCropFigureRendererTypeDegreeInformationBackground
    ,IDPCropFigureRendererTypeDarkDegreeInformationBackground
    ,IDPCropFigureRendererTypeBlueRatio3to4Button
    ,IDPCropFigureRendererTypeBlueRatio3to4ButtonHighlighted
    ,IDPCropFigureRendererTypeBlueRatio4to3Button
    ,IDPCropFigureRendererTypeBlueRatio4to3ButtonHighlighted
    ,IDPCropFigureRendererTypeBlueRotate90degreeButton
    ,IDPCropFigureRendererTypeBlueRotate90degreeButtonHighlighted
    ,IDPCropFigureRendererTypeBlueDegreeAdjustment
    ,IDPCropFigureRendererTypeBlueDegreeAdjustmentHighlighted
    ,IDPCropFigureRendererTypeBlueSquareButton
    ,IDPCropFigureRendererTypeBlueSquareButtonHighlighted
    ,IDPCropFigureRendererTypeMonoRatio3to4Button
    ,IDPCropFigureRendererTypeMonoRatio4to3Button
    ,IDPCropFigureRendererTypeMonoRotate90degreeButton
    ,IDPCropFigureRendererTypeMonoSquareButton
    ,IDPCropFigureRendererTypeMonoDegreeAdjustment
};

@class CCSprite;
@class CCSpriteBatchNode;

@interface IDPCropFigureRenderer : NSObject

+ (void) renderWithFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options;
+ (CGSize) sizeForFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options;
+ (UIImage*) createImageWithFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options;

@end
