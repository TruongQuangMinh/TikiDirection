//
//  CommonUtilities.h
//  TikiDirection
//
//  Created by LAP00195 on 7/6/16.
//  Copyright © 2016 LAP00195. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView(Animation)
+ (void)moveVerticalView:(UIView*)aView withRange:(CGFloat)range;
@end


@interface UIColor(HexColor)
+ (UIColor*)colorWithHexString:(NSString*)hexValue;
@end


@interface UIView (CornerRadius)
- (void)drawCornerLeftRadiusForView;
- (void)drawCornerRightRadiusForView;
@end
