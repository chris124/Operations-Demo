//
//  DisplayViewController.h
//  OperationsDemo
//
//  Created by Ankit Gupta on 6/6/11.
//  Copyright 2011 Pulse News. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DisplayViewController : UIViewController {
    
    UIActivityIndicatorView *loadingIndicator;
    UITextView *textView;
    
    NSData *data;
    NSString *sourceTitle;
}

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *sourceTitle;

@end
