#import "MyLocationPlugin.h"

@interface MyLocationPlugin()

@property(nonatomic, strong) BMKLocationManager *locationManager;
@property(nonatomic, assign) BOOL isNeedAddr;
@property(nonatomic, assign) BOOL isNeedHotSpot;
@property(nonatomic, copy) BMKLocatingCompletionBlock completionBlock;
@property(nonatomic, strong, nullable) FlutterResult myresult;

@end

@implementation MyLocationPlugin

- (void)dealloc {
    
    _myresult = nil;
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    
    _locationManager = nil;
    _completionBlock = nil;
}

-(void)initLocation
{
    _locationManager = [[BMKLocationManager alloc] init];
    
    _locationManager.delegate = self;
    
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.pausesLocationUpdatesAutomatically = YES;
    _locationManager.allowsBackgroundLocationUpdates = NO;
    _locationManager.locationTimeout = 10;
    _locationManager.reGeocodeTimeout = 10;
    
}

-(void)initBlock
{
    __weak MyLocationPlugin *weakSelf = self;
    self.completionBlock = ^(BMKLocation *location, BMKLocationNetworkState state, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
        }
        
        if (location.location) {//得到定位信息
            
            NSLog(@"LOC = %@",location.location);
//            NSLog(@"LOC ID= %@",location.locationID);
            
            NSNumber *longitude = [NSNumber numberWithDouble:location.location.coordinate.longitude];
            NSNumber *latitude = [NSNumber numberWithDouble:location.location.coordinate.latitude];
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:longitude, @"longitude", latitude, @"latitude", nil];
            
            MyLocationPlugin *strongSelf = weakSelf;
            [strongSelf returnLocation:dic];
        }
        
        if (location.rgcData) {
            NSLog(@"rgc = %@",[location.rgcData description]);
        }
        
        NSLog(@"netstate = %d",state);
    };
    
}

-(void) locate:(FlutterResult )result
{
    _myresult = result;
    [self initBlock];
    [self initLocation];
    _isNeedAddr = true;
    _isNeedHotSpot = false;
    
    [_locationManager requestLocationWithReGeocode:_isNeedAddr withNetworkState:_isNeedHotSpot completionBlock:self.completionBlock];
}

-(void) returnLocation: (NSDictionary *)loc
{
    NSLog(@"long: %@, lat: %@", [loc objectForKey:@"longitude"], [loc objectForKey:@"latitude"]);
    _myresult(loc);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"my_location"
            binaryMessenger:[registrar messenger]];
  MyLocationPlugin* instance = [[MyLocationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
  [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"Gs8v7lk8PvmBzMheMrwyUeLx29M99xXG" authDelegate:self];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"getLocation" isEqualToString:call.method]) {
      [self locate:result];
    
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
