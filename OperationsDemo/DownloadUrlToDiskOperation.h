//
//  DownloadUrlToDiskOperation.h
//  Pulse News
//
//  Created by Ankit Gupta on 1/6/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadUrlToDiskOperation : NSOperation {
  NSError*  error_;
	
  // In concurrent operations, we have to manage the operation's state
  BOOL executing_;
  BOOL finished_;
	
  // The actual NSURLConnection management
  NSURL*    connectionURL_;
  NSURLConnection*  connection_;
	
  // To save to disk
  NSString *filePath;
  NSOutputStream *stream;
}
@property (nonatomic,readonly) NSError* error;

@property(nonatomic, readonly) NSURL *connectionURL;
@property(nonatomic, retain) NSString *filePath;

-(id)initWithUrl:(NSURL *)aUrl saveToFilePath:(NSString *)aFilePath;

@end
