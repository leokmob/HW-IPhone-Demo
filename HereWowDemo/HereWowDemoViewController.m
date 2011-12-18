//
//  HereWowDemoViewController.m
//  HereWowDemo
//
//  Created by Leonid Kudryavtsev on 12/12/11.
//  Copyright 2011 self. All rights reserved.
//

#import "HereWowDemoViewController.h"

@implementation HereWowDemoViewController

@synthesize webView = _webView; 

- (void)dealloc
{
    [_webView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *fullPath = [NSString stringWithUTF8String:"http://ec2-50-16-158-234.compute-1.amazonaws.com:3000/m"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullPath]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
