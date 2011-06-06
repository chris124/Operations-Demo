//
//  RootViewController.m
//  OperationsDemo
//
//  Created by Ankit Gupta on 6/6/11.
//  Copyright 2011 Pulse News. All rights reserved.
//

#import "RootViewController.h"

#import "DisplayViewController.h"
#import "DownloadUrlOperation.h"

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    websites = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
    [websites setValue:@"http://google.com" forKey:@"Google"];
    [websites setValue:@"http://wikipedia.org" forKey:@"Wikipedia"];
    [websites setValue:@"http://pulse.me" forKey:@"Pulse.me"];
    [websites setValue:@"http://apple.com" forKey:@"Apple"];
    [websites setValue:@"http://twitter.com" forKey:@"Twitter"];

    self.title = @"Operations Demo";
    
    websiteData = [[NSMutableDictionary dictionaryWithCapacity:5] retain];

    // Create operation queue
    operationQueue = [NSOperationQueue new];
    // set maximum operations possible
    [operationQueue setMaxConcurrentOperationCount:2];
    
    // Add operations to download data
    for (NSString *key in [websites allKeys]) {
        NSString *urlAsString = [websites valueForKey:key];
        DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:urlAsString]];
        [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [operationQueue addOperation:operation]; // operation starts as soon as its added
        [operation release];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[websites allKeys] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    NSString *key = [[websites allKeys] objectAtIndex:[indexPath row]];
    cell.textLabel.text = key;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DisplayViewController *vc = [[DisplayViewController alloc] initWithNibName:@"DisplayViewController" bundle:nil];
    NSString *key = [[websites allKeys] objectAtIndex:[indexPath row]];
    vc.sourceTitle = key;
    if ([websiteData objectForKey:key]) {
        vc.data = [websiteData objectForKey:key];
    }
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [websites release];
    [super dealloc];
}

#pragma mark -
#pragma Actions
- (void)cancel:(id)sender {
    [operationQueue cancelAllOperations];
}

#pragma mark -
#pragma KVO Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
    if ([operation isKindOfClass:[DownloadUrlOperation class]]) {
        DownloadUrlOperation *downloadOperation = (DownloadUrlOperation *)operation;
        NSString *source = nil;
        for (NSString *key in [websites allKeys]) {
            if ([[websites valueForKey:key] isEqualToString:[downloadOperation.connectionURL absoluteString]]) {
                source = key;
                break;
            }
        }
        if (source) {
            NSLog(@"Downloaded finished from %@", source);
            NSData *data = [downloadOperation data];
            NSError * error = [downloadOperation error];
            if (error != nil) {
                // handle error
                // Notify that we have got an error downloading this data;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFailed"
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", error, @"error", nil]]; 
            
            } else {
                // Notify that we have got this source data;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFinished"
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", data, @"data", nil]]; 
                // save data
                [websiteData setValue:data forKey:source];
            }

        }
    }
}
@end
