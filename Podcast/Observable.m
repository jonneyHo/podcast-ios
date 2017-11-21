//
//  Observable.m
//  Podcast
//
//  Created by Drew Dunne on 11/20/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

#import "Observable.h"

@implementation Observable

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"masterProperty"]) {
        NSMutableSet *result = [NSMutableSet set];
        
        unsigned int count;
        objc_property_t *props = class_copyPropertyList([self class], &count);
        
        for (int i = 0; i < count; ++i){
            const char *propName = property_getName(props[i]);
            // Make sure "dummy" property does not affect itself
            if (strcmp(propName, "masterProperty"))
                [result addObject:[NSString stringWithUTF8String:propName]];
        }
        
        free(props);
        return result;
    }
    return nil;
}

@end
