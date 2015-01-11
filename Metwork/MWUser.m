//
//  MWUser.m
//  Metwork
//
//  Created by Kyle Yoon on 11/7/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "MWUser.h"
#import <Parse/PFSubclassing.h>

@implementation MWUser

@dynamic firstName;
@dynamic lastName;
@dynamic profileImageFile;
@dynamic shortDescription;
@dynamic jobTitle;
@dynamic company;
@dynamic skillOne;
@dynamic skillTwo;
@dynamic skillThree;
@dynamic need;
@dynamic major;
@dynamic minor;
@dynamic linkedInProfileURL;

+ (void)load {
    [self registerSubclass];
}

+ (MWUser *)currentUser {
    return (MWUser *)[PFUser currentUser];
}

+ (MWUser *)user {
    return (MWUser *)[PFUser user];
}

+ (void)retrieveUserWithObjectId:(NSString *)aObjectId completion:(void (^)(MWUser *user))completion {
    NSLog(@"Retrieving user");
    PFQuery *queryUsers = [MWUser query];
//    queryUsers.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [queryUsers whereKey:@"objectId" equalTo:aObjectId];
    [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"User query error: %@", error);
        } else {
            NSLog(@"User query: %@", objects.firstObject);
            NSLog(@"Used cached data: %d", [queryUsers hasCachedResult]);
            completion(objects.firstObject);
        }
    }];
}

@end
