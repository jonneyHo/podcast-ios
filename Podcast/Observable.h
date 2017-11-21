//
//  Observable.h
//  Podcast
//
//  Created by Drew Dunne on 11/20/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

@interface Observable : NSObject

@property (nonatomic) int masterProperty;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key;

@end
