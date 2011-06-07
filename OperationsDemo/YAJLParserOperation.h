//
//  YAJLParserOperation.h
//  Pulse News
//
//  Created by Ankit Gupta on 7/2/10.
//  Copyright 2010 Alphonso Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YAJL.h"

@interface YAJLParserOperation : NSOperation {
  NSError*  error_;

  YAJLDocument* document_;

  // In concurrent operations, we have to manage the operation's state
  BOOL executing_;
  BOOL finished_;

  // The actual NSURLConnection management
  NSURL*    connectionURL_;
  NSURLConnection*  connection_;
}

@property (nonatomic,readonly, getter = error) NSError* error_;
@property (nonatomic, readonly) NSURL *connectionURL;

@property (nonatomic,retain, getter = document) YAJLDocument* document_;

- (id)initWithURL:(NSURL*)url;
@end
