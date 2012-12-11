//
//  HelpViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/21/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

@synthesize helpView = _helpView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSString *helpPath;
    NSBundle *thisBundle = [NSBundle mainBundle];
    helpPath = [thisBundle pathForResource:@"help" ofType:@"html"];
    NSURL *helpURL = [NSURL fileURLWithPath:helpPath];
    [self.helpView loadRequest:[NSURLRequest requestWithURL:helpURL]];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
