//
//  NSArray+ZNKMASShorthandAdditions.h
//  ZNKMAsonry
//
//  Created by Jonas BudelZNKMAnn on 22/07/13.
//  Copyright (c) 2013 Jonas BudelZNKMAnn. All rights reserved.
//

#import "NSArray+ZNKMASAdditions.h"

#ifdef ZNKMAS_SHORTHAND

/**
 *	Shorthand array additions without the 'ZNKMAs_' prefixes,
 *  only enabled if ZNKMAS_SHORTHAND is defined
 */
@interface NSArray (ZNKMASShorthandAdditions)

- (NSArray *)ZNKMAkeConstraints:(void(^)(ZNKMASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(ZNKMASConstraintMaker *make))block;
- (NSArray *)reZNKMAkeConstraints:(void(^)(ZNKMASConstraintMaker *make))block;

@end

@implementation NSArray (ZNKMASShorthandAdditions)

- (NSArray *)ZNKMAkeConstraints:(void(^)(ZNKMASConstraintMaker *))block {
    return [self ZNKMAs_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(ZNKMASConstraintMaker *))block {
    return [self ZNKMAs_updateConstraints:block];
}

- (NSArray *)reZNKMAkeConstraints:(void(^)(ZNKMASConstraintMaker *))block {
    return [self ZNKMAs_reZNKMAkeConstraints:block];
}

@end

#endif
