//
//  UIViewController+ZNKMASAdditions.m
//  ZNKMAsonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+ZNKMASAdditions.h"

#ifdef ZNKMAS_VIEW_CONTROLLER

@implementation ZNKMAS_VIEW_CONTROLLER (ZNKMASAdditions)

- (ZNKMASViewAttribute *)ZNKMAs_topLayoutGuide {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ZNKMASViewAttribute *)ZNKMAs_topLayoutGuideTop {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ZNKMASViewAttribute *)ZNKMAs_topLayoutGuideBottom {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (ZNKMASViewAttribute *)ZNKMAs_bottomLayoutGuide {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ZNKMASViewAttribute *)ZNKMAs_bottomLayoutGuideTop {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ZNKMASViewAttribute *)ZNKMAs_bottomLayoutGuideBottom {
    return [[ZNKMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
