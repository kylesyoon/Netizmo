//
//  MWUser.h
//  Metwork
//
//  Created by Kyle Yoon on 11/7/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import <Parse/Parse.h>

@interface MWUser : PFUser <PFSubclassing>

@property NSString *firstName;
@property NSString *lastName;
@property PFFile *profileImageFile;
@property NSString *shortDescription;
@property NSString *jobTitle;
@property NSString *company;
@property NSString *skillOne;
@property NSString *skillTwo;
@property NSString *skillThree;
@property NSString *need;
@property NSNumber *major;
@property NSNumber *minor;
@property NSString *linkedInProfileURL;

+ (MWUser *)currentUser;
+ (MWUser *)user;
+ (void)retrieveUserWithObjectId:(NSString *)aObjectId completion:(void (^)(MWUser *user))completion ;

@end
