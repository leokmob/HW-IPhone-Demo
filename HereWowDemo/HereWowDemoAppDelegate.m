//
//  HereWowDemoAppDelegate.m
//  HereWowDemo
//
//  Created by Leonid Kudryavtsev on 12/12/11.
//  Copyright 2011 self. All rights reserved.
//

#import "HereWowDemoAppDelegate.h"
#import "HereWowDemoViewController.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation HereWowDemoAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize connection;
@synthesize data;

- (void)alertString:(NSString*) string
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [self failIfSimulator];
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];//zero badge on startup
    
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    //============
    //=
    // Here is where you set you view to the url passed in from above...
    //=
    //============
    // Get url from userInfo dictionary
    //============
    NSDictionary* userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo && [userInfo objectForKey:@"url"])
    {
        NSString *partPath = [userInfo objectForKey:@"url"];
        NSString *basePath = [NSString stringWithUTF8String:"http://ec2-50-16-158-234.compute-1.amazonaws.com:3000"];
        NSString *fullPath = [NSString stringWithFormat:@"%@%@", basePath, partPath];
        [self.viewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullPath]]];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UALOG(@"Application did become active.");
    [[UAPush shared] resetBadge]; //zero badge when resuming from background (iOS 4+)
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
    
    // LK: Register token on our own server
    
    //// This is straight fro UA getting started documentation...
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                                      stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString *registrationUrl = [NSString stringWithFormat:@"http://ec2-50-16-158-234.compute-1.amazonaws.com:3000/device/register/%@", deviceTokenString];
    NSURL *url = [NSURL URLWithString:registrationUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [self setConnection:[NSURLConnection connectionWithRequest:request delegate:self]];
    [self setData:[NSMutableData data]];
    
    [connection start];
    
    /*
     * Some example cases where user notifcation may be warranted
     *
     * This code will alert users who try to enable notifications
     * from the settings screen, but cannot do so because
     * notications are disabled in some capacity through the settings
     * app.
     * 
     */
    
    /*
     
     //Do something when notifications are disabled altogther
     if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
     UALOG(@"iOS Registered a device token, but nothing is enabled!");
     
     //only alert if this is the first registration, or if push has just been
     //re-enabled
     if ([UAirship shared].deviceToken != nil) { //already been set this session
     NSString* okStr = @"OK";
     NSString* errorMessage =
     @"Unable to turn on notifications. Use the \"Settings\" app to enable notifications.";
     NSString *errorTitle = @"Error";
     UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
     message:errorMessage
     delegate:nil
     cancelButtonTitle:okStr
     otherButtonTitles:nil];
     
     [someError show];
     [someError release];
     }
     
     //Do something when some notification types are disabled
     } else if ([application enabledRemoteNotificationTypes] != [UAPush shared].notificationTypes) {
     
     UALOG(@"Failed to register a device token with the requested services. Your notifications may be turned off.");
     
     //only alert if this is the first registration, or if push has just been
     //re-enabled
     if ([UAirship shared].deviceToken != nil) { //already been set this session
     
     UIRemoteNotificationType disabledTypes = [application enabledRemoteNotificationTypes] ^ [UAPush shared].notificationTypes;
     
     
     
     NSString* okStr = @"OK";
     NSString* errorMessage = [NSString stringWithFormat:@"Unable to turn on %@. Use the \"Settings\" app to enable these notifications.", [UAPush pushTypeString:disabledTypes]];
     NSString *errorTitle = @"Error";
     UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
     message:errorMessage
     delegate:nil
     cancelButtonTitle:okStr
     otherButtonTitles:nil];
     
     [someError show];
     [someError release];
     }
     }
     
     */
}

// Method if NSURLRequest delegate
- (void)connection:(NSURLConnection *)cnn didReceiveData:(NSData *)inData{
    [data appendData:inData];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    // parse headers, determine success of failure of registration....
}
-(void)connectionDidFinishLoading:(NSURLConnection *)conn {
    // Connection succeeded in downloading the request.
    NSLog( @"Succeeded! Received %d bytes of data", [data length] );
    
    // Convert received data into string.
    NSString * receivedString = [[NSString alloc] initWithData:data 
                                           encoding:NSASCIIStringEncoding];
    NSLog( @"From connectionDidFinishLoading: %@", receivedString );
    
    // release the connection, and the data object
    [conn release];
    [data release];
}
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [conn release];
    [data release];
    
    // inform the user
    [self alertString:@"Failed to register phone."];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

//=====================

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UALOG(@"Received remote notification: %@", userInfo);
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
    [[UAPush shared] resetBadge]; // zero badge after push received
    
    //============
    //=
    // Here is where you set you view to the url passed in from above...
    //=
    //============
    // Get url from userInfo dictionary
    //============
    // Concatenate string surch as /view/:id - id of the deal passed in.
    NSString *partPath = [userInfo objectForKey:@"url"];    
    if(partPath)
    {
        NSString *basePath = [NSString stringWithUTF8String:"http://ec2-50-16-158-234.compute-1.amazonaws.com:3000"];
        NSString *fullPath = [NSString stringWithFormat:@"%@%@", basePath, partPath];
        [self.viewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullPath]]];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [UAirship land];
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
        [self alertString:@"You will not be able to recieve push notifications in the simulator."];
    }
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
