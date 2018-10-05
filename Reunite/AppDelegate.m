 //
//  AppDelegate.m
//  ReUnite + TriagePic
//

//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "GAI.h"
#import <GoogleAppIndexing/GoogleAppIndexing.h>

@interface AppDelegate ()

@end



#define CURRENT_INIT_CODE @"6.6"


@implementation AppDelegate
{
    
    HomeViewController *_homeViewController;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    [self.window setTintColor:[UIColor colorWithRed:.2 green:.4 blue:.9 alpha:1]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    
    NSString *appIndexing = @"36994";

    [[GSDAppIndexing sharedInstance] registerApp:[appIndexing integerValue]];

     [GAI sharedInstance].trackUncaughtExceptions = YES;
//    
//    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
   [GAI sharedInstance].dispatchInterval = 1;
//    
//    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-45038-1"];
//
    
    //first time settings inititialization
    NSString *firstTimeInitString = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_FIRST_TIME_CODE];
    if (![firstTimeInitString isEqualToString:CURRENT_INIT_CODE]) {
        [self firstTimeInit];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // getting an NSString
    NSString *myString = [prefs stringForKey:@"languageString"];
   
    if (![language isEqualToString:myString])
    {
       // NSLog(@"LanguageStringLanguageStringLanguageStringLanguageString%@",myString);
        UIAlertView *alertlanguage=[[UIAlertView alloc]initWithTitle:@"Reunite" message:@"Delete the App and Download again from the App store" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertlanguage show];
        
       // self.window.userInteractionEnabled=NO;
        
       // self.window.backgroundColor = [UIColor blackColor];
        //self.window.alpha = 0.2;


//self.window.opaque = NO;
        alertlanguage.tag = 1;
    }
    
    _homeViewController = [[HomeViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_homeViewController];
    return YES;
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * restorableObjects))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        
        if ([[userActivity.webpageURL absoluteString] hasPrefix:@"https://"]) {
            NSString *str=[userActivity.webpageURL absoluteString];
            NSArray *Array = [str componentsSeparatedByString:@"="];
            NSString *ConfirmCode = [Array objectAtIndex:1];
            
            [WSCommon confirmUser:ConfirmCode delegate:self];
            
           // NSLog(@"%@",ConfirmCode);
            
        }
    }
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [WSCommon pingWithDelegate:_homeViewController];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Custom Init
- (void)firstTimeInit
{
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] objectForKey:language];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:language forKey:@"languageString"];
    //so not to do it again
    [[NSUserDefaults standardUserDefaults] setObject:CURRENT_INIT_CODE forKey:GLOBAL_KEY_FIRST_TIME_CODE];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_STATUS_PRIVACY_AGREE];
    
    //PL servers:
    [[NSUserDefaults standardUserDefaults] setObject:@"https://" forKey:GLOBAL_KEY_SERVER_HTTP];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:GLOBAL_KEY_SERVER_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:GLOBAL_KEY_SERVER_API_VERSION];

    // Unique ID for Local Storage
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:GLOBAL_KEY_CURRENT_UNIQUE_ID];
    
    //init the Settings
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_SETTINGS_GPS_INACCURATE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_SETTINGS_FAMILY_NAME];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_SETTINGS_STATUS];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_SETTINGS_LOCATION];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_SETTINGS_AUTO_UPLOAD];
    
    //init the sticky
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:GLOBAL_KEY_SAVED_LOCATION];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:GLOBAL_KEY_SAVED_FAMILY_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:@"Missing" forKey:GLOBAL_KEY_SAVED_STATUS];
    
    //initializing Filter
    for (NSString *key in [[PersonObject statusDictionaryUpload] allKeys]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:key]];
    }
    
    for (NSString *key in [[PersonObject genderDictionaryUpload] allKeys]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:key]];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_CHILD];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_ADULT];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_UNKNOWN];
    [[NSUserDefaults standardUserDefaults] setObject:@(50).stringValue forKey:FILTER_PER_PAGE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FILTER_CONTAIN_IMAGE];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FILTER_EXACT_STRING];
    
    

   
    
    // Get the event Lists
    [WSCommon removeToken];
    [WSCommon getEventDataWithDelegate:nil];
    
    //[[NSUserDefaults standardUserDefaults] setObject:@{} forKey:GLOBAL_KEY_QUE_DELETE_DICT];
    
    // Server choices
    NSArray *endpointsArray = @[@"https://", @"https://"];
    [[NSUserDefaults standardUserDefaults] setObject:endpointsArray forKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY];
}


- (void)wsconfirmCodeWithSuccess:(BOOL)success error:(id)error
{
    [SVProgressHUD dismiss];
    
    if (success) {
        UIAlertView *registerSuccessAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Your Account is Activated", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [registerSuccessAlert show];
     
    } else {
        UIAlertView *registerFailedAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Unable to Activate", nil) message:error delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil, nil];
        [registerFailedAlert show];
    }
}


+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 15;
}



@end
