//
//  ViewController.m
//  ZaHunter
//
//  Created by S on 10/15/14.
//  Copyright (c) 2014 Ryan Siska. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PizzaPlace.h"

@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>
@property CLLocationManager *locationManager;
@property NSMutableArray *unorderedPizzaPlaces;
@property CLLocation *usersLocation;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *locatedPizzaPlaces;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unorderedPizzaPlaces = [[NSMutableArray alloc] init];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    //[self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    self.locatedPizzaPlaces = [NSMutableArray new];
}

- (IBAction)onFindPizzaButtonPressed:(id)sender
{
    [self.unorderedPizzaPlaces removeAllObjects];
    [self.locatedPizzaPlaces removeAllObjects];
    [self.locationManager startUpdatingLocation];
    NSLog(@"Button Pressed");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"That didn't work at all");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self getPizzaPlaces:location];
            self.usersLocation = location;
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

-(void) getPizzaPlaces:(CLLocation *)location
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];

    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(5, 5));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        NSArray *arrayOfPizzaPlaces = response.mapItems;
        NSLog(@"arrayOfPizzaPlaces before iteration: %@", arrayOfPizzaPlaces);
        for (MKMapItem *mapItem in arrayOfPizzaPlaces)
        {
            PizzaPlace *pizzaPlace = [[PizzaPlace alloc] init];
            pizzaPlace.nameOfPlace = mapItem.name;
            pizzaPlace.addressCoordinate = mapItem.placemark;
            //NSLog(@"%@", pizzaPlace.nameOfPlace);
            [self.unorderedPizzaPlaces addObject:pizzaPlace];
        }
        NSLog(@"arrayOfPizzaPlaces after iteration: %@",arrayOfPizzaPlaces);
        [self getDistanceFromUser];
    }];
}

- (void)getDistanceFromUser
{
    for (PizzaPlace *tempPizzaPlace in self.unorderedPizzaPlaces)
    {
        CLLocation *firstLocation = [[CLLocation alloc]initWithLatitude:tempPizzaPlace.addressCoordinate.coordinate.latitude longitude:tempPizzaPlace.addressCoordinate.coordinate.longitude];
        CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:self.usersLocation.coordinate.latitude longitude:self.usersLocation.coordinate.longitude];

        CLLocationDistance newDistance = [secondLocation distanceFromLocation:firstLocation];
        PizzaPlace *pizzaPlace = [[PizzaPlace alloc] init];
        pizzaPlace.nameOfPlace = tempPizzaPlace.nameOfPlace;
        pizzaPlace.addressCoordinate = tempPizzaPlace.addressCoordinate;
        pizzaPlace.distanceFromUser = newDistance * 0.000621371;

        //fill a different mutable array here; not the one youre enumerating through
        [self.locatedPizzaPlaces addObject:pizzaPlace];
        NSLog(@"Distance gotten from user section: %@", self.locatedPizzaPlaces);
    }
    [self orderTheArraysBasedOnDistance];
}

- (void)orderTheArraysBasedOnDistance
{
    [self.locatedPizzaPlaces sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES]]];
    [self.tableView reloadData];
}

//now you just need to order the array based on unorderedPizzaPlaces distanceFromUser - call that in tempPizzaPlace and then do the tableview stuff

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCellID" forIndexPath:indexPath];
    PizzaPlace *place = [self.locatedPizzaPlaces objectAtIndex:indexPath.row];
    cell.textLabel.text = place.nameOfPlace;

    NSString *distanceString = [NSString stringWithFormat:@"%f miles away from you.", place.distanceFromUser];
    cell.detailTextLabel.text = distanceString;

    return cell;
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.unorderedPizzaPlaces.count;
    return self.locatedPizzaPlaces.count;
}









@end
