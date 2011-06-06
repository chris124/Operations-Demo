//
//  DisplayViewController.m
//  OperationsDemo
//
//  Created by Ankit Gupta on 6/6/11.
//  Copyright 2011 Pulse News. All rights reserved.
//

#import "DisplayViewController.h"


@implementation DisplayViewController

@synthesize loadingIndicator, textView, data, sourceTitle;

#pragma mark -
#pragma Loading Data
- (void)loadData {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    textView.hidden = NO;
    textView.text = dataString;
    [loadingIndicator stopAnimating];
}
- (void)dataAvailable:(NSNotification *)notification {
    NSString *source = [notification.userInfo valueForKey:@"source"];
    if ([self.sourceTitle isEqualToString:source]) {
        self.data = [notification.userInfo valueForKey:@"data"];
        [self loadData];
    }
}
- (void)dataUnAvailable:(NSNotification *)notification {
    NSString *source = [notification.userInfo valueForKey:@"source"];
    if ([self.sourceTitle isEqualToString:source]) {
        [loadingIndicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed" message:@"Please check internet connection and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.loadingIndicator = nil;
    self.data = nil;
    self.sourceTitle = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (data) {
        [self loadData];
    }
    else {
        [loadingIndicator startAnimating];
        textView.hidden = YES;   
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(dataAvailable:)
         name:@"DataDownloadFinished"
         object:nil ] ;

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(dataUnavailable:)
         name:@"DataDownloadFailed"
         object:nil ] ;

    }
    self.title = sourceTitle;
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.textView = nil;
    self.loadingIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
