//
//  HereWowDemoAppDelegate.h
//  HereWowDemo
//
//  Created by Leonid Kudryavtsev on 12/12/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HereWowDemoViewController;

@interface HereWowDemoAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet HereWowDemoViewController *viewController;

- (void)failIfSimulator;
- (void)alertString:(NSString*) string;

@property (retain, nonatomic) NSURLConnection * connection;
@property (retain, nonatomic) NSMutableData * data;

@end
