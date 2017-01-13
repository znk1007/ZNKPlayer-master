//
//  UIView+ZNKMASAdditions.m
//  ZNKMAsonry
//
//  Created by Jonas BudelZNKMAnn on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+ZNKMASAdditions.h"
#import <objc/runtime.h>

@implementation ZNKMAS_VIEW (ZNKMASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(ZNKMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ZNKMASConstraintMaker *constraintZNKMAker = [[ZNKMASConstraintMaker alloc] initWithView:self];
    block(constraintZNKMAker);
    return [constraintZNKMAker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(ZNKMASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ZNKMASConstraintMaker *constraintZNKMAker = [[ZNKMASConstraintMaker alloc] initWithView:self];
    constraintZNKMAker.updateExisting = YES;
    block(constraintZNKMAker);
    return [constraintZNKMAker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(ZNKMASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ZNKMASConstraintMaker *constraintZNKMAker = [[ZNKMASConstraintMaker alloc] initWithView:self];
    constraintZNKMAker.removeExisting = YES;
    block(constraintZNKMAker);
    return [constraintZNKMAker install];
}

#pragma mark - NSLayoutAttribute properties

- (ZNKMASViewAttribute *)ZNKMAs_left {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (ZNKMASViewAttribute *)ZNKMAs_top {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (ZNKMASViewAttribute *)ZNKMAs_right {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (ZNKMASViewAttribute *)ZNKMAs_bottom {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (ZNKMASViewAttribute *)ZNKMAs_leading {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (ZNKMASViewAttribute *)ZNKMAs_trailing {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (ZNKMASViewAttribute *)ZNKMAs_width {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (ZNKMASViewAttribute *)ZNKMAs_height {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (ZNKMASViewAttribute *)ZNKMAs_centerX {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (ZNKMASViewAttribute *)ZNKMAs_centerY {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (ZNKMASViewAttribute *)ZNKMAs_baseline {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (ZNKMASViewAttribute *(^)(NSLayoutAttribute))ZNKMAs_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__ZNKMAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ZNKMASViewAttribute *)ZNKMAs_firstBaseline {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (ZNKMASViewAttribute *)ZNKMAs_lastBaseline {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ZNKMASViewAttribute *)ZNKMAs_leftMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_rightMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_topMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_bottomMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_leadingMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_trailingMargin {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (ZNKMASViewAttribute *)ZNKMAs_centerXWithinMargins {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ZNKMASViewAttribute *)ZNKMAs_centerYWithinMargins {
    return [[ZNKMASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - associated properties

- (id)ZNKMAs_key {
    return objc_getAssociatedObject(self, @selector(ZNKMAs_key));
}

- (void)setZNKMAs_key:(id)key {
    objc_setAssociatedObject(self, @selector(ZNKMAs_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)ZNKMAs_closestCommonSuperview:(ZNKMAS_VIEW *)view {
    ZNKMAS_VIEW *closestCommonSuperview = nil;

    ZNKMAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        ZNKMAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
