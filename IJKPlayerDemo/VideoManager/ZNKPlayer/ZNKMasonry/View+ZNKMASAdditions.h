//
//  UIView+ZNKMASAdditions.h
//  ZNKMAsonry
//
//  Created by Jonas BudelZNKMAnn on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ZNKMASUtilities.h"
#import "ZNKMASConstraintmaker.h"
#import "ZNKMASViewAttribute.h"

/**
 *	Provides constraint ZNKMAker block
 *  and convience methods for creating ZNKMASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface ZNKMAS_VIEW (ZNKMASAdditions)

/**
 *	following properties return a new ZNKMASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_left;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_top;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_right;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_bottom;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_leading;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_trailing;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_width;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_height;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_centerX;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_centerY;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_baseline;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *(^ZNKMAs_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__ZNKMAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_firstBaseline;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_leftMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_rightMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_topMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_bottomMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_leadingMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_trailingMargin;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_centerXWithinMargins;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_centerYWithinMargins;

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id ZNKMAs_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)ZNKMAs_closestCommonSuperview:(ZNKMAS_VIEW *)view;

/**
 *  Creates a ZNKMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created ZNKMASConstraints
 */
- (NSArray *)ZNKMAs_makeConstraints:(void(NS_NOESCAPE ^)(ZNKMASConstraintMaker *ZNKMAke))block;

/**
 *  Creates a ZNKMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ZNKMASConstraints
 */
- (NSArray *)ZNKMAs_updateConstraints:(void(NS_NOESCAPE ^)(ZNKMASConstraintMaker *ZNKMAke))block;

/**
 *  Creates a ZNKMASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ZNKMASConstraints
 */
- (NSArray *)ZNKMAs_reZNKMAkeConstraints:(void(NS_NOESCAPE ^)(ZNKMASConstraintMaker *ZNKMAke))block;

@end
