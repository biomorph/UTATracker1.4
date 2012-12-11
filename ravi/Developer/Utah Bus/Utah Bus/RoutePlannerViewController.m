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
    self.back.style = UIBarButtonItemStyleBordered;
    [buttons addObject:self.back];
    self.forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goforward)];
    self.forward.style = UIBarButtonItemStyleBordered;
    [buttons addObject:self.forward];
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshpage)];
    self.refresh.style = UIBarButtonItemStyleBordered;
    [buttons addObject:self.refresh];
    self.UTATransit = [[UIBarButtonItem alloc] initWithTitle:@"UTA" style:UIBarButtonItemStyleBordered target:self action:@selector(UTAtransit)];
    self.googleTransit = [[UIBarButtonItem alloc] initWithTitle:@"Google" style:UIBarButtonItemStyleBordered target:self action:@selector(viewDidLoad)];
    // Add buttons to toolbar and toolbar to nav bar.
    self.navigationItem.leftBarButtonItems=buttons;
    [buttons removeAllObjects];
    [buttons addObject:self.UTATransit];
    [buttons addObject:self.googleTransit];
    
    self.navigationItem.rightBarButtonItems = buttons;
    
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

- (void)UTAtransit
{
    NSString *googleTransitUrlString = [NSString stringWithFormat:@"http://www.rideuta.com/ridinguta/tripplanner/planner.aspx"];
    NSURL *googleTransitURL = [NSURL URLWithString:googleTransitUrlString];
    [self.routePlannerWebView loadRequest:[NSURLRequest requestWithURL:googleTransitURL]];
    [self updateButtons];
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
    //self.navigationItem.title = @"Route Planner";
    NSString *routePlannerUrlString =[NSString stringWithFormat:@"https://www.google.com/maps?tm=1#bmb=1"];
    NSURL *routePlannerURL = [NSURL URLWithString:routePlannerUrlString];
    [self.routePlannerWebView loadRequest:[NSURLRequest requestWithURL:routePlannerURL]];
    [self updateButtons];
    
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
