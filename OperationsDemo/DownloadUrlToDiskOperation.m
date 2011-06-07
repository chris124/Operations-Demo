//
//  DownloadUrlToDiskOperation.m
//  Pulse News
//
//  Created by Ankit Gupta on 1/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "DownloadUrlToDiskOperation.h"

@implementation DownloadUrlToDiskOperation

@synthesize error = error_, connectionURL = connectionURL_, filePath;

- (void)dealloc
{
	if( connection_ ) { 
        [connection_ cancel]; 
        [connection_ release]; 
        connection_ = nil;
        
        [stream close];
		[stream release];
		stream = nil;
    }
    
	[connectionURL_ release];
    connectionURL_ = nil;
    
	[error_ release];
	error_ = nil;
	
    self.filePath = nil;
    
    [super dealloc];
}


-(id)initWithUrl:(NSURL *)aUrl saveToFilePath:(NSString *)aFilePath {
	if ((self = [super init])) {
		connectionURL_ = [aUrl copy];
		self.filePath = aFilePath;
		stream = [[NSOutputStream alloc] initToFileAtPath:aFilePath append:NO];
        
	}
	return self;
}

#pragma mark -
#pragma mark Start & Utility Methods

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    if( connection_ ) {
		[connection_ cancel];
        [connection_ release];
        connection_ = nil;

		[stream close];
		[stream release];
		stream = nil;
		
    }
	
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)cancelled {
	// Code for cancelled
    error_ = [[NSError alloc] initWithDomain:@"DownloadUrlToDiskOperation"
                                        code:123
                                    userInfo:nil];
	
    [self done];	
}
- (void)start
{
    // Ensure this operation is not being restarted and that it has not been cancelled
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    if( finished_ || [self isCancelled] ) { [self done]; return; }
    
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    [self willChangeValueForKey:@"isExecuting"];
    executing_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
	
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    connection_ = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:connectionURL_ cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0]
                                                  delegate:self];
	
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing_;
}

- (BOOL)isFinished
{
    return finished_;
}
#pragma mark -

#pragma mark Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	if([self isCancelled]) {
        [self cancelled];
		return;
    }
	else {
		error_ = [error retain];
		[self done];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if([self isCancelled]) {
        [self cancelled];
		return;
    }
    // dump the data
    // Write to disk.
	int success = [stream write:[data bytes] maxLength:[data length]];
	if (success < 0) {
		error_ = [[NSError alloc] initWithDomain:@"DownloadUrlToDiskOperation"
                                            code:1
                                        userInfo:[NSDictionary dictionaryWithObject:@"Error writing to disk" forKey:NSLocalizedDescriptionKey]];		
        [self done];
	}
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([self isCancelled]) {
        [self cancelled];
		return;
    }
	
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if( statusCode == 200 ) {
        [stream open];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"DownloadUrlToDiskOperationDomain"
                                            code:statusCode
                                        userInfo:userInfo];
        [self done];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if([self isCancelled]) {
        [self cancelled];
		return;
    }
	else {
		[self done];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
