//
//  UIViewController+ZNKMASAdditions.h
//  ZNKMAsonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ZNKMASUtilities.h"
#import "ZNKMASConstraintmaker.h"
#import "ZNKMASViewAttribute.h"

#ifdef ZNKMAS_VIEW_CONTROLLER

@interface ZNKMAS_VIEW_CONTROLLER (ZNKMASAdditions)

/**
 *	following properties return a new ZNKMASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_topLayoutGuide;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_bottomLayoutGuide;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_topLayoutGuideTop;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) ZNKMASViewAttribute *ZNKMAs_bottomLayoutGuideBottom;


@end

#endif
