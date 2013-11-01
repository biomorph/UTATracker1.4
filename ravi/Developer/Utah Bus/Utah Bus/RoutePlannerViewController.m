//
//  RoutePlannerViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 10/8/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "RoutePlannerViewController.h"

@interface RoutePlannerViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIBarButtonItem *back;
@property (nonatomic, strong) UIBarButtonItem *forward;
@property (nonatomic, strong) UIBarButtonItem *refresh;
@property (nonatomic, strong) UIBarButtonItem *UTATransit;
@property (nonatomic, strong) UIBarButtonItem *googleTransit;
@end

@implementation RoutePlannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:4];
    
    self.back = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goback)];
    [buttons addObject:self.back];
    self.forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goforward)];
    [buttons addObject:self.forward];
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshpage)];
    [buttons addObject:self.refresh];
    
    self.navigationItem.leftBarButtonItems=buttons;
    [self updateButtons];
    
}

- (void) goback
{
    [self.routePlannerWebView goBack];
}

- (void) goforward
{
    [self.routePlannerWebView goForward];
}

- (void) refreshpage
{
    [self.routePlannerWebView reload];
}


- (void) updateButtons
{
    self.back.enabled = self.routePlannerWebView.canGoBack;
    self.forward.enabled = self.routePlannerWebView.canGoForward;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.routePlannerWebView.delegate = self;
    self.spinner.hidesWhenStopped=YES;
    NSString *routePlannerUrlString =[NSString stringWithFormat:@"https://www.google.com/maps?tm=1"];
    NSURL *routePlannerURL = [NSURL URLWithString:routePlannerUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:routePlannerURL];
    [self.routePlannerWebView loadRequest:request];
    
    [self updateButtons];
    
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self.spinner startAnimating];
    [self updateButtons];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    [self updateButtons];
}


- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.spinner stopAnimating];
    [self updateButtons];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
   [self updateButtons];
     return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
