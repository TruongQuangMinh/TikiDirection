//
//  CommonUtilities.m
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import "CommonUtilities.h"

@implementation UIView(Animation)

+ (void)moveVerticalView:(UIView*)aView withRange:(CGFloat)range {
    [UIView animateWithDuration:0.3
                     animations:^(void){
                         CGRect frame = aView.frame;
                         frame.origin.y += range;
                         aView.frame = frame;
                     }
                     completion:nil];
}

@end


@implementation UIColor(HexColor)

+ (UIColor*)colorWithHexString:(NSString*)hexValue
{
    NSString *cleanedHexValue = [hexValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    unsigned long rgbColorValue = strtoul([[cleanedHexValue substringToIndex:6] cStringUsingEncoding:NSASCIIStringEncoding], NULL, 16);
    
    NSUInteger redValue   = (rgbColorValue >> 16) & 0xFF;
    NSUInteger greenValue = (rgbColorValue >>  8) & 0xFF;
    NSUInteger blueValue  = (rgbColorValue >>  0) & 0xFF;
    
    return [UIColor colorWithRed:(redValue / 255.0) green:(greenValue / 255.0) blue:(blueValue / 255.0) alpha:1.0];
}

@end


@implementation UIView (CornerRadius)

- (void)drawCornerLeftRadiusForView {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(4.0, 4.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

- (void)drawCornerRightRadiusForView {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(4.0, 4.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

@end
