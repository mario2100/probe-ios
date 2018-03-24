#import "TestOverviewViewController.h"

@interface TestOverviewViewController ()

@end

@implementation TestOverviewViewController
@synthesize testName;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = NSLocalizedString(self.testName, nil);
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLastMeasurement) name:@"networkTestEnded" object:nil];

    [self.testNameLabel setText:NSLocalizedString(self.testName, nil)];
    
    NSString *testDesc = [NSString stringWithFormat:@"%@_longdesc", testName];
    [self.testDescriptionLabel setText:NSLocalizedString(testDesc, nil)];

    //TODO Estimated Time test
    [self.timeLabel setText:@"2min 10MB"];
    
    [self reloadLastMeasurement];
    [self.testImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_white", testName]]];
    defaultColor = [SettingsUtility getColorForTest:testName];
    [self.runButton setTitleColor:defaultColor forState:UIControlStateNormal];
    [self.backgroundView setBackgroundColor:defaultColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:defaultColor];
}

-(void)reloadLastMeasurement{
    SRKResultSet *results = [[[[[Result query] limit:1] where:[NSString stringWithFormat:@"name = '%@'", testName]] orderByDescending:@"startTime"] fetch];
    
    if ([results count] > 0){
        NSInteger daysAgo = [self daysBetweenTwoDates:[[results objectAtIndex:0] startTime]];
        if (daysAgo < 2)
            [self.lastRunLabel setText:[NSString stringWithFormat:@"%ld %@", daysAgo, NSLocalizedString(@"day_ago", nil)]];
        else
            [self.lastRunLabel setText:[NSString stringWithFormat:@"%ld %@", daysAgo, NSLocalizedString(@"days_ago", nil)]];
    }
    else
        [self.lastRunLabel setText:NSLocalizedString(@"never", nil)];
}

-(NSInteger)daysBetweenTwoDates:(NSDate*)testDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:testDate
                                                          toDate:[NSDate date]
                                                         options:0];
    return components.day;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    }
}

-(IBAction)run:(id)sender{
    if ([[ReachabilityManager sharedManager].reachability currentReachabilityStatus] != NotReachable)
        [self performSegueWithIdentifier:@"toTestRun" sender:self];
    else
        [MessageUtility alertWithTitle:@"warning" message:@"no_internet" inView:self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toTestRun"]){
        TestRunningViewController *vc = (TestRunningViewController * )segue.destinationViewController;
        if ([testName isEqualToString:@"websites"])
            [vc setCurrentTest:[[WCNetworkTest alloc] init]];
        else if ([testName isEqualToString:@"performance"])
            [vc setCurrentTest:[[SPNetworkTest alloc] init]];
        else if ([testName isEqualToString:@"middle_boxes"])
            [vc setCurrentTest:[[MBNetworkTest alloc] init]];
        else if ([testName isEqualToString:@"instant_messaging"])
            [vc setCurrentTest:[[IMNetworkTest alloc] init]];
    }
    else if ([[segue identifier] isEqualToString:@"toTestSettings"]){
        SettingsTableViewController *vc = (SettingsTableViewController * )segue.destinationViewController;
        [vc setTestName:testName];
    }

}


@end