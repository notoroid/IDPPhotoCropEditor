//
//  IDPCropFigureRenderer.m
//  
//
//  Created by Noto Kaname on 12/05/03.
//  Copyright (c) 2012年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPCropFigureRenderer.h"
#import <AVFoundation/AVFoundation.h>
#import "IDPPhotoCropEditorConstants.h"

@implementation IDPCropFigureRenderer

+ (void) renderWithFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options
{
    switch (IDPCropFigureRendererType) {
    case IDPCropFigureRendererTypeCropArea:
        {
            CGRect frame = [options[IDP_CROP_CROPAREA_FRAME_NAME] CGRectValue];
            CGFloat cropAspectRatio = [options[IDP_CROP_CROPAREA_ASPECT_RAOTO_NAME] floatValue];
            UIEdgeInsets edgeInsets = [options[IDP_CROP_CROPAREA_ASPECT_EDGE_INSETS_NAME] UIEdgeInsetsValue];
            IDPCropViewFrameType frameType = [options[IDP_CROP_CROPAREA_FRAME_TYPE] integerValue];
            
            CGRect innerRect = UIEdgeInsetsInsetRect(frame, edgeInsets);
            CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(innerRect.size.width, innerRect.size.width * (1 / cropAspectRatio) ), innerRect);
            
//            NSLog(@"cropRect=%@", [NSValue valueWithCGRect:cropRect] );

            //// Color Declarations
            UIColor* color3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
            
            //// Color Declarations
            UIColor* colorLine2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5];
            
            if (frameType == IDPCropViewFrameTypeDefault || frameType == IDPCropViewFrameTypeDetail) {
                //// Rectangle Drawing
                UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:cropRect];
                
                [colorLine2 setStroke];
                rectanglePath.lineWidth = 1.5;
                [rectanglePath stroke];
                
                
                [color3 setStroke];
                rectanglePath.lineWidth = 1;
                [rectanglePath stroke];
            }
            
            if (frameType == IDPCropViewFrameTypeDefault || frameType == IDPCropViewFrameTypeDetail ) {
            
                CGFloat width = CGRectGetWidth(cropRect);
                CGFloat height = CGRectGetHeight(cropRect);

                for (NSInteger i = 0; i < 3; i++) {
                    if (i > 0) {
                        
                        UIBezierPath* bezierLinePath = [UIBezierPath bezierPath];
                        [bezierLinePath moveToPoint: CGPointMake(CGRectGetMinX(cropRect),CGRectGetMinY(cropRect) + height / 3 * i)];
                        [bezierLinePath addLineToPoint: CGPointMake(CGRectGetMaxX(cropRect),CGRectGetMinY(cropRect)+ height / 3 * i)];
                        
                        UIBezierPath* bezierLine2Path = [UIBezierPath bezierPath];
                        [bezierLine2Path moveToPoint: CGPointMake(CGRectGetMinX(cropRect) + width / 3 * i,CGRectGetMinY(cropRect))];
                        [bezierLine2Path addLineToPoint: CGPointMake(CGRectGetMinX(cropRect)+ width / 3 * i,CGRectGetMaxY(cropRect))];
                        
                        UIBezierPath *bezierMargePath =[UIBezierPath bezierPath];
                        [bezierMargePath appendPath:bezierLinePath];
                        [bezierMargePath appendPath:bezierLine2Path];
                        [colorLine2 setStroke];
                        bezierMargePath.lineWidth = 1.5f;
                        [bezierMargePath stroke];
                    }
                }
                
                for (NSInteger i = 0; i < 3; i++) {
                    if (i > 0) {
                        //// Bezier 2 Drawing
                        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                        [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(cropRect),CGRectGetMinY(cropRect) + height / 3 * i)];
                        [bezier2Path addLineToPoint: CGPointMake(CGRectGetMaxX(cropRect),CGRectGetMinY(cropRect)+ height / 3 * i)];
                        
                        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
                        [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(cropRect) + width / 3 * i,CGRectGetMinY(cropRect))];
                        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(cropRect)+ width / 3 * i,CGRectGetMaxY(cropRect))];
                        
                        UIBezierPath *bezierMargePath =[UIBezierPath bezierPath];
                        [bezierMargePath appendPath:bezier2Path];
                        [bezierMargePath appendPath:bezier4Path];
                        [color3 setStroke];
                        bezierMargePath.lineWidth = 1;
                        [bezierMargePath stroke];
                    }
                }
            }
            
            if (frameType == IDPCropViewFrameTypeDetail ) {
                
                CGFloat width = CGRectGetWidth(cropRect);
                CGFloat height = CGRectGetHeight(cropRect);

                CGSize edge = CGSizeMake(CGRectGetMinX(cropRect)+ width / 6 * 2,CGRectGetMinY(cropRect)+ height / 6 * 2 );
                CGFloat horizontalStepCandidate = edge.width / floor(edge.width / (4.0));
                CGFloat verticalStepCandidate = edge.height / floor(edge.height / (4.0));
                CGFloat marginX = horizontalStepCandidate - 2.5;
                CGFloat marginY = verticalStepCandidate - 2.5;
                
                //// Color Declarations
                UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
                UIColor* color2 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.39];
                
                for (NSInteger i2 = 1; i2 < 7; i2+=1) {
                    if(i2 > 0){
                        CGFloat verticalBegin = CGRectGetMinY(cropRect)+ height / 6 * (i2-1) + marginY * 2.0f;
                        CGFloat verticalEnd = CGRectGetMinY(cropRect)+ height / 6 * i2 - marginY * 1.0f;
                        
                        CGFloat verticalStep = (verticalEnd-verticalBegin) / floor((verticalEnd-verticalBegin) / (4.0));
                        
                        for (NSInteger i = 1; i < 6; i+=2) {
                            if(i > 0){
                                CGFloat horizonPosition = CGRectGetMinX(cropRect)+ width / 6 * i - (2.5 * .5f);
                                
                                for( CGFloat y = verticalBegin; y < verticalEnd- (2.5 * .5f); y += verticalStep ){
                                    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(horizonPosition, y, 2.5, 2.5)];
                                    [color setFill];
                                    [oval3Path fill];
                                    [color2 setStroke];
                                    oval3Path.lineWidth = 0.5;
                                    [oval3Path stroke];
                                }
                                
                            }
                        }
                    
                    }
                }
                
                for (NSInteger i2 = 1; i2 < 7; i2+=1) {
                    if(i2 > 0){
                        CGFloat horizontalBegin = CGRectGetMinX(cropRect)+ width / 6 * (i2-1) + marginX * 2.0f;
                        CGFloat horizontalEnd = CGRectGetMinX(cropRect)+ width / 6 * i2 - marginX * 1.0f;
                        
                        CGFloat horizontalStep = (horizontalEnd-horizontalBegin) / floor((horizontalEnd-horizontalBegin) / (4.0));
                        
                        for (NSInteger i = 1; i < 6; i+=2) {
                            if(i > 0){
                                CGFloat verticalPosition = CGRectGetMinY(cropRect)+ height / 6 * i - (2.5 * .5f);
                                
                                for( CGFloat x = horizontalBegin; x < horizontalEnd- (2.5 * .5f); x += horizontalStep ){
                                    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(x, verticalPosition, 2.5, 2.5)];
                                    [color setFill];
                                    [oval3Path fill];
                                    [color2 setStroke];
                                    oval3Path.lineWidth = 0.5;
                                    [oval3Path stroke];
                                }
                                
                            }
                        }
                        
                    }
                }
                
                for (NSInteger i2 = 1; i2 < 6; i2+=2) {
                    if(i2 > 0){
                        for (NSInteger i = 1; i < 6; i+=2) {
                            if(i > 0){
                                CGPoint center = CGPointMake(CGRectGetMinX(cropRect)+ width / 6 * i,CGRectGetMinY(cropRect)+ height / 6 * i2 );
                                
                                UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(center.x - 2.5 * .5f, center.y - 2.5 * .5f, 2.5, 2.5)];
                                [color setFill];
                                [oval3Path fill];
                                [color2 setStroke];
                                oval3Path.lineWidth = 0.5;
                                [oval3Path stroke];
                            }
                        }
                    }
                }
                
            }
            
        }
        break;
    case IDPCropFigureRendererTypeTracker:
        {
            //// Color Declarations
            UIColor* color3 = [UIColor colorWithRed: 0.928 green: 0.928 blue: 0.928 alpha: 1];
            UIColor* color4 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.405];
            
            //// Oval 2 Drawing
            UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(7.5, 7.5, 29.5, 29.5)];
            [color3 setFill];
            [oval2Path fill];
            [color4 setStroke];
            oval2Path.lineWidth = 1.5;
            [oval2Path stroke];
        }
        break;
    case IDPCropFigureRendererTypeResetDegree:
        {
            //// Color Declarations
            UIColor* color2 = [UIColor colorWithRed: 0.039 green: 0.376 blue: 1 alpha: 1];
            
            //// Oval Drawing
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 18, 18)];
            [color2 setStroke];
            ovalPath.lineWidth = 2;
            [ovalPath stroke];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(15.78, 6.61)];
            [bezier3Path addLineToPoint: CGPointMake(11.89, 10.5)];
            [bezier3Path addLineToPoint: CGPointMake(15.78, 14.39)];
            [bezier3Path addLineToPoint: CGPointMake(14.39, 15.78)];
            [bezier3Path addLineToPoint: CGPointMake(10.5, 11.89)];
            [bezier3Path addLineToPoint: CGPointMake(6.61, 15.78)];
            [bezier3Path addLineToPoint: CGPointMake(5.22, 14.39)];
            [bezier3Path addLineToPoint: CGPointMake(9.11, 10.5)];
            [bezier3Path addLineToPoint: CGPointMake(5.22, 6.61)];
            [bezier3Path addLineToPoint: CGPointMake(6.61, 5.22)];
            [bezier3Path addLineToPoint: CGPointMake(10.5, 9.11)];
            [bezier3Path addLineToPoint: CGPointMake(14.39, 5.22)];
            [bezier3Path addLineToPoint: CGPointMake(15.78, 6.61)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
        }
        break;
    case IDPCropFigureRendererTypeDarkResetDegree:
        {
            //// Color Declarations
            UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
            UIColor* color2 = [UIColor colorWithRed: 0.533 green: 0.6 blue: 0.651 alpha: 1];
            
            //// Oval Drawing
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2.5, 1.5, 18, 18)];
            [color setFill];
            [ovalPath fill];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(16.78, 6.61)];
            [bezier3Path addLineToPoint: CGPointMake(12.89, 10.5)];
            [bezier3Path addLineToPoint: CGPointMake(16.78, 14.39)];
            [bezier3Path addLineToPoint: CGPointMake(15.39, 15.78)];
            [bezier3Path addLineToPoint: CGPointMake(11.5, 11.89)];
            [bezier3Path addLineToPoint: CGPointMake(7.61, 15.78)];
            [bezier3Path addLineToPoint: CGPointMake(6.22, 14.39)];
            [bezier3Path addLineToPoint: CGPointMake(10.11, 10.5)];
            [bezier3Path addLineToPoint: CGPointMake(6.22, 6.61)];
            [bezier3Path addLineToPoint: CGPointMake(7.61, 5.22)];
            [bezier3Path addLineToPoint: CGPointMake(11.5, 9.11)];
            [bezier3Path addLineToPoint: CGPointMake(15.39, 5.22)];
            [bezier3Path addLineToPoint: CGPointMake(16.78, 6.61)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
        }
        break;
    case IDPCropFigureRendererTypeDegreeInformationBackground:
        {
            //// Color Declarations
            UIColor* color2 = [UIColor colorWithRed: 0.039 green: 0.376 blue: 1 alpha: 1];
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 1.5, 68.5, 28.5) cornerRadius: 2];
            [[UIColor whiteColor] setFill];
            [roundedRectanglePath fill];
            [color2 setStroke];
            roundedRectanglePath.lineWidth = 1;
            [roundedRectanglePath stroke];
        }
        break;
    case IDPCropFigureRendererTypeDarkDegreeInformationBackground:
        {
            //// Color Declarations
            UIColor* color2 = [UIColor colorWithRed: 0.533 green: 0.6 blue: 0.651 alpha: 1];
            UIColor* color = [UIColor colorWithRed: 0.533 green: 0.6 blue: 0.651 alpha: 1];
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 1.5, 68.5, 28.5) cornerRadius: 2];
            [color setFill];
            [roundedRectanglePath fill];
            [color2 setStroke];
            roundedRectanglePath.lineWidth = 1;
            [roundedRectanglePath stroke];
        }
        break;
    case IDPCropFigureRendererTypeBlueRatio3to4Button:
        {
            //// Color Declarations
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            
            //// Text Drawing
            CGRect textRect = CGRectMake(2, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
            textStyle.alignment = NSTextAlignmentCenter;
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: UIFont.labelFontSize], NSForegroundColorAttributeName: color2, NSParagraphStyleAttributeName: textStyle};
            
            [@"3:4" drawInRect: textRect withAttributes: textFontAttributes];
            
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = UIBezierPath.bezierPath;
            [bezierPath moveToPoint: CGPointMake(23.75, 3.5)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 6)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 6)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 3.5)];
            [bezierPath addCurveToPoint: CGPointMake(22.5, 2.75) controlPoint1: CGPointMake(23.25, 3.09) controlPoint2: CGPointMake(22.91, 2.75)];
            [bezierPath addLineToPoint: CGPointMake(7, 2.75)];
            [bezierPath addCurveToPoint: CGPointMake(6.25, 3.5) controlPoint1: CGPointMake(6.59, 2.75) controlPoint2: CGPointMake(6.25, 3.09)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 6)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 6)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 3.5)];
            [bezierPath addCurveToPoint: CGPointMake(7, 2.25) controlPoint1: CGPointMake(5.75, 2.81) controlPoint2: CGPointMake(6.31, 2.25)];
            [bezierPath addLineToPoint: CGPointMake(22.5, 2.25)];
            [bezierPath addCurveToPoint: CGPointMake(23.75, 3.5) controlPoint1: CGPointMake(23.19, 2.25) controlPoint2: CGPointMake(23.75, 2.81)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(23.75, 25.5)];
            [bezierPath addCurveToPoint: CGPointMake(22.5, 26.75) controlPoint1: CGPointMake(23.75, 26.19) controlPoint2: CGPointMake(23.19, 26.75)];
            [bezierPath addLineToPoint: CGPointMake(7, 26.75)];
            [bezierPath addCurveToPoint: CGPointMake(5.75, 25.5) controlPoint1: CGPointMake(6.31, 26.75) controlPoint2: CGPointMake(5.75, 26.19)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 22)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 22)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 25.5)];
            [bezierPath addCurveToPoint: CGPointMake(7, 26.25) controlPoint1: CGPointMake(6.25, 25.91) controlPoint2: CGPointMake(6.59, 26.25)];
            [bezierPath addLineToPoint: CGPointMake(22.5, 26.25)];
            [bezierPath addCurveToPoint: CGPointMake(23.25, 25.5) controlPoint1: CGPointMake(22.91, 26.25) controlPoint2: CGPointMake(23.25, 25.91)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 22)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 22)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 25.5)];
            [bezierPath closePath];
            [color2 setFill];
            [bezierPath fill];

        }
        break;
    case IDPCropFigureRendererTypeBlueRatio3to4ButtonHighlighted:
        {
            //// Color Declarations
            UIColor* color = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            
            //// Abstracted Attributes
            NSString* textContent = @"3:4";
            
            //// Text Drawing
            CGRect textRect = CGRectMake(2, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: [UIFont labelFontSize]], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
            
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(23.75, 3.5)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 6)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 6)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 3.5)];
            [bezierPath addCurveToPoint: CGPointMake(22.5, 2.75) controlPoint1: CGPointMake(23.25, 3.09) controlPoint2: CGPointMake(22.91, 2.75)];
            [bezierPath addLineToPoint: CGPointMake(7, 2.75)];
            [bezierPath addCurveToPoint: CGPointMake(6.25, 3.5) controlPoint1: CGPointMake(6.59, 2.75) controlPoint2: CGPointMake(6.25, 3.09)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 6)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 6)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 3.5)];
            [bezierPath addCurveToPoint: CGPointMake(7, 2.25) controlPoint1: CGPointMake(5.75, 2.81) controlPoint2: CGPointMake(6.31, 2.25)];
            [bezierPath addLineToPoint: CGPointMake(22.5, 2.25)];
            [bezierPath addCurveToPoint: CGPointMake(23.75, 3.5) controlPoint1: CGPointMake(23.19, 2.25) controlPoint2: CGPointMake(23.75, 2.81)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(23.75, 25.5)];
            [bezierPath addCurveToPoint: CGPointMake(22.5, 26.75) controlPoint1: CGPointMake(23.75, 26.19) controlPoint2: CGPointMake(23.19, 26.75)];
            [bezierPath addLineToPoint: CGPointMake(7, 26.75)];
            [bezierPath addCurveToPoint: CGPointMake(5.75, 25.5) controlPoint1: CGPointMake(6.31, 26.75) controlPoint2: CGPointMake(5.75, 26.19)];
            [bezierPath addLineToPoint: CGPointMake(5.75, 22)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 22)];
            [bezierPath addLineToPoint: CGPointMake(6.25, 25.5)];
            [bezierPath addCurveToPoint: CGPointMake(7, 26.25) controlPoint1: CGPointMake(6.25, 25.91) controlPoint2: CGPointMake(6.59, 26.25)];
            [bezierPath addLineToPoint: CGPointMake(22.5, 26.25)];
            [bezierPath addCurveToPoint: CGPointMake(23.25, 25.5) controlPoint1: CGPointMake(22.91, 26.25) controlPoint2: CGPointMake(23.25, 25.91)];
            [bezierPath addLineToPoint: CGPointMake(23.25, 22)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 22)];
            [bezierPath addLineToPoint: CGPointMake(23.75, 25.5)];
            [bezierPath closePath];
            [color2 setFill];
            [bezierPath fill];
        }
        break;
    case IDPCropFigureRendererTypeBlueRatio4to3Button:
        {
            //// Color Declarations
            UIColor* color = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            
            //// Abstracted Attributes
            NSString* textContent = @"4:3";
            
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 5, 26, 18.5) cornerRadius: 1];
            [color2 setStroke];
            roundedRectanglePath.lineWidth = 0.5;
            [roundedRectanglePath stroke];
            
            
            //// Text Drawing
            CGRect textRect = CGRectMake(1, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: [UIFont labelFontSize]], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
        break;
    case IDPCropFigureRendererTypeBlueRatio4to3ButtonHighlighted:
        {
            //// Color Declarations
            UIColor* color = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            
            //// Abstracted Attributes
            NSString* textContent = @"4:3";
            
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 5, 26, 18.5) cornerRadius: 1];
            [color2 setStroke];
            roundedRectanglePath.lineWidth = 0.5;
            [roundedRectanglePath stroke];
            
            
            //// Text Drawing
            CGRect textRect = CGRectMake(1, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: [UIFont labelFontSize]], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
        break;
    case IDPCropFigureRendererTypeBlueRotate90degreeButton:
        {
            //// Color Declarations
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            UIColor* color3 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            
            //// Abstracted Attributes
            NSString* text2Content = @"90°";
            
            
            //// Text 2 Drawing
            CGRect text2Rect = CGRectMake(5, 7, 18, 14);
            NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [text2Style setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 9.5], NSForegroundColorAttributeName: color3, NSParagraphStyleAttributeName: text2Style};
            
            [text2Content drawInRect: text2Rect withAttributes: text2FontAttributes];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(21.49, 5.67)];
            [bezier3Path addCurveToPoint: CGPointMake(24.86, 16.44) controlPoint1: CGPointMake(24.3, 8.6) controlPoint2: CGPointMake(25.43, 12.63)];
            [bezier3Path addLineToPoint: CGPointMake(28.15, 13.15)];
            [bezier3Path addLineToPoint: CGPointMake(28.85, 13.85)];
            [bezier3Path addLineToPoint: CGPointMake(24.85, 17.85)];
            [bezier3Path addLineToPoint: CGPointMake(24.5, 18.21)];
            [bezier3Path addLineToPoint: CGPointMake(24.15, 17.85)];
            [bezier3Path addLineToPoint: CGPointMake(20.15, 13.85)];
            [bezier3Path addLineToPoint: CGPointMake(20.85, 13.15)];
            [bezier3Path addLineToPoint: CGPointMake(23.88, 16.18)];
            [bezier3Path addCurveToPoint: CGPointMake(20.77, 6.36) controlPoint1: CGPointMake(24.37, 12.7) controlPoint2: CGPointMake(23.33, 9.03)];
            [bezier3Path addCurveToPoint: CGPointMake(5.23, 6.36) controlPoint1: CGPointMake(16.48, 1.88) controlPoint2: CGPointMake(9.52, 1.88)];
            [bezier3Path addCurveToPoint: CGPointMake(5.23, 22.64) controlPoint1: CGPointMake(0.92, 10.85) controlPoint2: CGPointMake(0.92, 18.15)];
            [bezier3Path addCurveToPoint: CGPointMake(20.77, 22.64) controlPoint1: CGPointMake(9.52, 27.12) controlPoint2: CGPointMake(16.48, 27.12)];
            [bezier3Path addLineToPoint: CGPointMake(21.49, 23.33)];
            [bezier3Path addCurveToPoint: CGPointMake(4.51, 23.33) controlPoint1: CGPointMake(16.8, 28.22) controlPoint2: CGPointMake(9.2, 28.22)];
            [bezier3Path addCurveToPoint: CGPointMake(4.51, 5.67) controlPoint1: CGPointMake(-0.17, 18.45) controlPoint2: CGPointMake(-0.17, 10.55)];
            [bezier3Path addCurveToPoint: CGPointMake(21.49, 5.67) controlPoint1: CGPointMake(9.2, 0.78) controlPoint2: CGPointMake(16.8, 0.78)];
            [bezier3Path closePath];
            [bezier3Path moveToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path addCurveToPoint: CGPointMake(21.49, 23.33) controlPoint1: CGPointMake(21.99, 22.79) controlPoint2: CGPointMake(21.75, 23.06)];
            [bezier3Path addLineToPoint: CGPointMake(20.77, 22.64)];
            [bezier3Path addLineToPoint: CGPointMake(20.9, 22.5)];
            [bezier3Path addLineToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path addLineToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
        }
        break;
    case IDPCropFigureRendererTypeBlueRotate90degreeButtonHighlighted:
        {
            //// Color Declarations
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            UIColor* color3 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            
            //// Abstracted Attributes
            NSString* text2Content = @"90°";
            
            
            //// Text 2 Drawing
            CGRect text2Rect = CGRectMake(5, 7, 18, 14);
            NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [text2Style setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 9.5], NSForegroundColorAttributeName: color3, NSParagraphStyleAttributeName: text2Style};
            
            [text2Content drawInRect: text2Rect withAttributes: text2FontAttributes];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(21.49, 5.67)];
            [bezier3Path addCurveToPoint: CGPointMake(24.86, 16.44) controlPoint1: CGPointMake(24.3, 8.6) controlPoint2: CGPointMake(25.43, 12.63)];
            [bezier3Path addLineToPoint: CGPointMake(28.15, 13.15)];
            [bezier3Path addLineToPoint: CGPointMake(28.85, 13.85)];
            [bezier3Path addLineToPoint: CGPointMake(24.85, 17.85)];
            [bezier3Path addLineToPoint: CGPointMake(24.5, 18.21)];
            [bezier3Path addLineToPoint: CGPointMake(24.15, 17.85)];
            [bezier3Path addLineToPoint: CGPointMake(20.15, 13.85)];
            [bezier3Path addLineToPoint: CGPointMake(20.85, 13.15)];
            [bezier3Path addLineToPoint: CGPointMake(23.88, 16.18)];
            [bezier3Path addCurveToPoint: CGPointMake(20.77, 6.36) controlPoint1: CGPointMake(24.37, 12.7) controlPoint2: CGPointMake(23.33, 9.03)];
            [bezier3Path addCurveToPoint: CGPointMake(5.23, 6.36) controlPoint1: CGPointMake(16.48, 1.88) controlPoint2: CGPointMake(9.52, 1.88)];
            [bezier3Path addCurveToPoint: CGPointMake(5.23, 22.64) controlPoint1: CGPointMake(0.92, 10.85) controlPoint2: CGPointMake(0.92, 18.15)];
            [bezier3Path addCurveToPoint: CGPointMake(20.77, 22.64) controlPoint1: CGPointMake(9.52, 27.12) controlPoint2: CGPointMake(16.48, 27.12)];
            [bezier3Path addLineToPoint: CGPointMake(21.49, 23.33)];
            [bezier3Path addCurveToPoint: CGPointMake(4.51, 23.33) controlPoint1: CGPointMake(16.8, 28.22) controlPoint2: CGPointMake(9.2, 28.22)];
            [bezier3Path addCurveToPoint: CGPointMake(4.51, 5.67) controlPoint1: CGPointMake(-0.17, 18.45) controlPoint2: CGPointMake(-0.17, 10.55)];
            [bezier3Path addCurveToPoint: CGPointMake(21.49, 5.67) controlPoint1: CGPointMake(9.2, 0.78) controlPoint2: CGPointMake(16.8, 0.78)];
            [bezier3Path closePath];
            [bezier3Path moveToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path addCurveToPoint: CGPointMake(21.49, 23.33) controlPoint1: CGPointMake(21.99, 22.79) controlPoint2: CGPointMake(21.75, 23.06)];
            [bezier3Path addLineToPoint: CGPointMake(20.77, 22.64)];
            [bezier3Path addLineToPoint: CGPointMake(20.9, 22.5)];
            [bezier3Path addLineToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path addLineToPoint: CGPointMake(22.22, 22.5)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
        }
        break;
    case IDPCropFigureRendererTypeBlueSquareButton:
        {
            //// Color Declarations
            UIColor* color = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            
            //// Abstracted Attributes
            NSString* textContent = @"1:1";
            
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(3.5, 3, 22, 22) cornerRadius: 1];
            [color setStroke];
            roundedRectanglePath.lineWidth = 0.5;
            [roundedRectanglePath stroke];
            
            
            //// Text Drawing
            CGRect textRect = CGRectMake(1, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: [UIFont labelFontSize]], NSForegroundColorAttributeName: color2, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
        break;
    case IDPCropFigureRendererTypeBlueSquareButtonHighlighted:
        {
            //// Color Declarations
            UIColor* color = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            
            //// Abstracted Attributes
            NSString* textContent = @"1:1";
            
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(3.5, 3, 22, 22) cornerRadius: 1];
            [color setStroke];
            roundedRectanglePath.lineWidth = 0.5;
            [roundedRectanglePath stroke];
            
            
            //// Text Drawing
            CGRect textRect = CGRectMake(1, 4, 28, 24);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSTextAlignmentCenter];
            
            NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: [UIFont labelFontSize]], NSForegroundColorAttributeName: color2, NSParagraphStyleAttributeName: textStyle};
            
            [textContent drawInRect: textRect withAttributes: textFontAttributes];
        }
        break;
    case IDPCropFigureRendererTypeBlueDegreeAdjustment:
        {
            //// Color Declarations
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1];
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 7.93) controlPoint1: CGPointMake(7.83, 5.75) controlPoint2: CGPointMake(6.24, 6.62)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 22.07) controlPoint1: CGPointMake(1.02, 11.83) controlPoint2: CGPointMake(1.02, 18.17)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 24.68) controlPoint1: CGPointMake(6.24, 23.38) controlPoint2: CGPointMake(7.83, 24.25)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 25.71)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 22.78) controlPoint1: CGPointMake(7.57, 25.26) controlPoint2: CGPointMake(5.73, 24.29)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 7.22) controlPoint1: CGPointMake(-0.07, 18.48) controlPoint2: CGPointMake(-0.07, 11.52)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 4.29) controlPoint1: CGPointMake(5.73, 5.71) controlPoint2: CGPointMake(7.57, 4.74)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath closePath];
            [color2 setFill];
            [bezierPath fill];
            
            
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(4.5, 4.5)];
            [bezier2Path addLineToPoint: CGPointMake(9, 5)];
            [bezier2Path addLineToPoint: CGPointMake(7.5, 9.5)];
            [color2 setStroke];
            bezier2Path.lineWidth = 1;
            [bezier2Path stroke];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 22.07) controlPoint1: CGPointMake(21.17, 24.25) controlPoint2: CGPointMake(22.76, 23.38)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 7.93) controlPoint1: CGPointMake(27.98, 18.17) controlPoint2: CGPointMake(27.98, 11.83)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 5.32) controlPoint1: CGPointMake(22.76, 6.62) controlPoint2: CGPointMake(21.17, 5.75)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 4.29)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 7.22) controlPoint1: CGPointMake(21.43, 4.74) controlPoint2: CGPointMake(23.27, 5.71)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 22.78) controlPoint1: CGPointMake(29.07, 11.52) controlPoint2: CGPointMake(29.07, 18.48)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 25.71) controlPoint1: CGPointMake(23.27, 24.29) controlPoint2: CGPointMake(21.43, 25.26)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
            
            
            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
            [bezier4Path moveToPoint: CGPointMake(24.5, 25.5)];
            [bezier4Path addLineToPoint: CGPointMake(20, 25)];
            [bezier4Path addLineToPoint: CGPointMake(21.5, 20.5)];
            [color2 setStroke];
            bezier4Path.lineWidth = 1;
            [bezier4Path stroke];
            
            
            //// Bezier 5 Drawing
            UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
            [bezier5Path moveToPoint: CGPointMake(-0.5, 14.5)];
            [bezier5Path addLineToPoint: CGPointMake(29.5, 14.5)];
            [color2 setStroke];
            bezier5Path.lineWidth = 1;
            CGFloat bezier5Pattern[] = {2, 2, 2, 2};
            [bezier5Path setLineDash: bezier5Pattern count: 4 phase: 0];
            [bezier5Path stroke];
            
            
            //// Bezier 6 Drawing
            UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
            [bezier6Path moveToPoint: CGPointMake(14.5, -0.5)];
            [bezier6Path addLineToPoint: CGPointMake(14.5, 29.5)];
            [color2 setStroke];
            bezier6Path.lineWidth = 1;
            CGFloat bezier6Pattern[] = {2, 2, 2, 2};
            [bezier6Path setLineDash: bezier6Pattern count: 4 phase: 0];
            [bezier6Path stroke];
            
            
            //// Oval Drawing
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(10.5, 10.5, 8, 8)];
            [color2 setStroke];
            ovalPath.lineWidth = 1;
            [ovalPath stroke];
        }
        break;
    case IDPCropFigureRendererTypeBlueDegreeAdjustmentHighlighted:
        {
            //// Color Declarations
            UIColor* color5 = options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_HIGHLIGHTED_COLOR] : [UIColor colorWithRed: 0 green: 0.478 blue: 1 alpha: 1];
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 7.93) controlPoint1: CGPointMake(7.83, 5.75) controlPoint2: CGPointMake(6.24, 6.62)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 22.07) controlPoint1: CGPointMake(1.02, 11.83) controlPoint2: CGPointMake(1.02, 18.17)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 24.68) controlPoint1: CGPointMake(6.24, 23.38) controlPoint2: CGPointMake(7.83, 24.25)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 25.71)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 22.78) controlPoint1: CGPointMake(7.57, 25.26) controlPoint2: CGPointMake(5.73, 24.29)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 7.22) controlPoint1: CGPointMake(-0.07, 18.48) controlPoint2: CGPointMake(-0.07, 11.52)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 4.29) controlPoint1: CGPointMake(5.73, 5.71) controlPoint2: CGPointMake(7.57, 4.74)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath closePath];
            [color5 setFill];
            [bezierPath fill];
            
            
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(4.5, 4.5)];
            [bezier2Path addLineToPoint: CGPointMake(9, 5)];
            [bezier2Path addLineToPoint: CGPointMake(7.5, 9.5)];
            [color5 setStroke];
            bezier2Path.lineWidth = 1;
            [bezier2Path stroke];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 22.07) controlPoint1: CGPointMake(21.17, 24.25) controlPoint2: CGPointMake(22.76, 23.38)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 7.93) controlPoint1: CGPointMake(27.98, 18.17) controlPoint2: CGPointMake(27.98, 11.83)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 5.32) controlPoint1: CGPointMake(22.76, 6.62) controlPoint2: CGPointMake(21.17, 5.75)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 4.29)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 7.22) controlPoint1: CGPointMake(21.43, 4.74) controlPoint2: CGPointMake(23.27, 5.71)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 22.78) controlPoint1: CGPointMake(29.07, 11.52) controlPoint2: CGPointMake(29.07, 18.48)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 25.71) controlPoint1: CGPointMake(23.27, 24.29) controlPoint2: CGPointMake(21.43, 25.26)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path closePath];
            [color5 setFill];
            [bezier3Path fill];
            
            
            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
            [bezier4Path moveToPoint: CGPointMake(24.5, 25.5)];
            [bezier4Path addLineToPoint: CGPointMake(20, 25)];
            [bezier4Path addLineToPoint: CGPointMake(21.5, 20.5)];
            [color5 setStroke];
            bezier4Path.lineWidth = 1;
            [bezier4Path stroke];
            
            
            //// Bezier 5 Drawing
            UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
            [bezier5Path moveToPoint: CGPointMake(-0.5, 14.5)];
            [bezier5Path addLineToPoint: CGPointMake(29.5, 14.5)];
            [color5 setStroke];
            bezier5Path.lineWidth = 1;
            CGFloat bezier5Pattern[] = {2, 2, 2, 2};
            [bezier5Path setLineDash: bezier5Pattern count: 4 phase: 0];
            [bezier5Path stroke];
            
            
            //// Bezier 6 Drawing
            UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
            [bezier6Path moveToPoint: CGPointMake(14.5, -0.5)];
            [bezier6Path addLineToPoint: CGPointMake(14.5, 29.5)];
            [color5 setStroke];
            bezier6Path.lineWidth = 1;
            CGFloat bezier6Pattern[] = {2, 2, 2, 2};
            [bezier6Path setLineDash: bezier6Pattern count: 4 phase: 0];
            [bezier6Path stroke];
            
            
            //// Oval Drawing
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(10.5, 10.5, 8, 8)];
            [color5 setStroke];
            ovalPath.lineWidth = 1;
            [ovalPath stroke];
        }
        break;
    case IDPCropFigureRendererTypeMonoDegreeAdjustment:
        {
            //// Color Declarations
            UIColor* color2 = options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] ? options[IDP_CROP_TOOLBAR_BUTTON_NORMAL_COLOR] : [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
            
            //// Bezier Drawing
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 7.93) controlPoint1: CGPointMake(7.83, 5.75) controlPoint2: CGPointMake(6.24, 6.62)];
            [bezierPath addCurveToPoint: CGPointMake(4.93, 22.07) controlPoint1: CGPointMake(1.02, 11.83) controlPoint2: CGPointMake(1.02, 18.17)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 24.68) controlPoint1: CGPointMake(6.24, 23.38) controlPoint2: CGPointMake(7.83, 24.25)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 25.71)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 22.78) controlPoint1: CGPointMake(7.57, 25.26) controlPoint2: CGPointMake(5.73, 24.29)];
            [bezierPath addCurveToPoint: CGPointMake(4.22, 7.22) controlPoint1: CGPointMake(-0.07, 18.48) controlPoint2: CGPointMake(-0.07, 11.52)];
            [bezierPath addCurveToPoint: CGPointMake(9.5, 4.29) controlPoint1: CGPointMake(5.73, 5.71) controlPoint2: CGPointMake(7.57, 4.74)];
            [bezierPath addLineToPoint: CGPointMake(9.5, 5.32)];
            [bezierPath closePath];
            [color2 setFill];
            [bezierPath fill];
            
            
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(4.5, 4.5)];
            [bezier2Path addLineToPoint: CGPointMake(9, 5)];
            [bezier2Path addLineToPoint: CGPointMake(7.5, 9.5)];
            [color2 setStroke];
            bezier2Path.lineWidth = 1;
            [bezier2Path stroke];
            
            
            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 22.07) controlPoint1: CGPointMake(21.17, 24.25) controlPoint2: CGPointMake(22.76, 23.38)];
            [bezier3Path addCurveToPoint: CGPointMake(24.07, 7.93) controlPoint1: CGPointMake(27.98, 18.17) controlPoint2: CGPointMake(27.98, 11.83)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 5.32) controlPoint1: CGPointMake(22.76, 6.62) controlPoint2: CGPointMake(21.17, 5.75)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 4.29)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 7.22) controlPoint1: CGPointMake(21.43, 4.74) controlPoint2: CGPointMake(23.27, 5.71)];
            [bezier3Path addCurveToPoint: CGPointMake(24.78, 22.78) controlPoint1: CGPointMake(29.07, 11.52) controlPoint2: CGPointMake(29.07, 18.48)];
            [bezier3Path addCurveToPoint: CGPointMake(19.5, 25.71) controlPoint1: CGPointMake(23.27, 24.29) controlPoint2: CGPointMake(21.43, 25.26)];
            [bezier3Path addLineToPoint: CGPointMake(19.5, 24.68)];
            [bezier3Path closePath];
            [color2 setFill];
            [bezier3Path fill];
            
            
            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
            [bezier4Path moveToPoint: CGPointMake(24.5, 25.5)];
            [bezier4Path addLineToPoint: CGPointMake(20, 25)];
            [bezier4Path addLineToPoint: CGPointMake(21.5, 20.5)];
            [color2 setStroke];
            bezier4Path.lineWidth = 1;
            [bezier4Path stroke];
            
            
            //// Bezier 5 Drawing
            UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
            [bezier5Path moveToPoint: CGPointMake(-0.5, 14.5)];
            [bezier5Path addLineToPoint: CGPointMake(29.5, 14.5)];
            [color2 setStroke];
            bezier5Path.lineWidth = 1;
            CGFloat bezier5Pattern[] = {2, 2, 2, 2};
            [bezier5Path setLineDash: bezier5Pattern count: 4 phase: 0];
            [bezier5Path stroke];
            
            
            //// Bezier 6 Drawing
            UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
            [bezier6Path moveToPoint: CGPointMake(14.5, -0.5)];
            [bezier6Path addLineToPoint: CGPointMake(14.5, 29.5)];
            [color2 setStroke];
            bezier6Path.lineWidth = 1;
            CGFloat bezier6Pattern[] = {2, 2, 2, 2};
            [bezier6Path setLineDash: bezier6Pattern count: 4 phase: 0];
            [bezier6Path stroke];
            
            
            //// Oval Drawing
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(10.5, 10.5, 8, 8)];
            [color2 setStroke];
            ovalPath.lineWidth = 1;
            [ovalPath stroke];
        }
        break;
    default:
        break;
    }
}

+ (CGSize) sizeForFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options
{
    CGSize size = CGSizeZero;
    switch (IDPCropFigureRendererType) {
    case IDPCropFigureRendererTypeCropArea:
        {
            CGRect frame = [options[IDP_CROP_CROPAREA_FRAME_NAME] CGRectValue];
            size = frame.size;
        }
        break;
    case IDPCropFigureRendererTypeTracker:
        size = CGSizeMake(44.0f, 44.0f);
        break;
    case IDPCropFigureRendererTypeResetDegree:
    case IDPCropFigureRendererTypeDarkResetDegree:
        size = CGSizeMake(21.0f, 21.0f);
        break;
    case IDPCropFigureRendererTypeDegreeInformationBackground:
    case IDPCropFigureRendererTypeDarkDegreeInformationBackground:
        size = CGSizeMake(71.0f, 31.0f);
        break;
    case IDPCropFigureRendererTypeBlueRatio3to4Button:
    case IDPCropFigureRendererTypeBlueRatio3to4ButtonHighlighted:
    case IDPCropFigureRendererTypeBlueRatio4to3Button:
    case IDPCropFigureRendererTypeBlueRatio4to3ButtonHighlighted:
    case IDPCropFigureRendererTypeBlueRotate90degreeButton:
    case IDPCropFigureRendererTypeBlueRotate90degreeButtonHighlighted:
    case IDPCropFigureRendererTypeBlueSquareButton:
    case IDPCropFigureRendererTypeBlueSquareButtonHighlighted:
    case IDPCropFigureRendererTypeBlueDegreeAdjustment:
    case IDPCropFigureRendererTypeBlueDegreeAdjustmentHighlighted:
    case IDPCropFigureRendererTypeMonoRatio3to4Button:
    case IDPCropFigureRendererTypeMonoRatio4to3Button:
    case IDPCropFigureRendererTypeMonoRotate90degreeButton:
    case IDPCropFigureRendererTypeMonoSquareButton:
    case IDPCropFigureRendererTypeMonoDegreeAdjustment:
        size = CGSizeMake(29.0f,29.0f);
        break;
    default:
        break;
    }
    return size;
}

+ (UIImage*) createImageWithFigureType:(IDPCropFigureRendererType)IDPCropFigureRendererType options:(NSDictionary*)options
{
    CGSize sizeImage = [IDPCropFigureRenderer sizeForFigureType:IDPCropFigureRendererType options:options];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sizeImage.width ,sizeImage.height ) , NO , [UIScreen mainScreen].scale );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    
    [IDPCropFigureRenderer renderWithFigureType:IDPCropFigureRendererType options:options];
    
    CGContextRestoreGState(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();        
    
    return image;
}

@end
