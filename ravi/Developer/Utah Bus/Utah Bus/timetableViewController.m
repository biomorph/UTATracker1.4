//
//  timetableViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/24/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
// To display a UIWebview with the timetable of a selected bus, queries UTA's website

#import "timetableViewController.h"

@interface timetableViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation timetableViewController
@synthesize vehicleDirection = _vehicleDirection;

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
    self.timetableView.delegate = self;
    self.spinner.hidesWhenStopped = YES;
    self.navigationItem.title = [NSString stringWithFormat:@"TimeTable Route %@",self.route];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *components = [gregorian components:units fromDate:date];
    NSUInteger weekDay = [components weekday];
    //NSLog(@"date is %@ and weekDay is %d",date, weekDay);
    if (weekDay == 1)self.day = @"3";
    else if (weekDay == 7)self.day = @"2";
    else self.day = @"4";
    NSString *timetableUrlString =[NSString stringWithFormat:@"http://www.rideuta.com/ridinguta/routes/schedule.aspx?abbreviation=%@&dir=%@&service=%@&signup=122",self.route, self.vehicleDirection, self.day];
    NSURL *timetableURL = [NSURL URLWithString:timetableUrlString];
    [self.timetableView loadRequest:[NSURLRequest requestWithURL:timetableURL]];
    
    
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = YES;
    [self.spinner stopAnimating];
    
}
- (void)viewDidUnload
{
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
