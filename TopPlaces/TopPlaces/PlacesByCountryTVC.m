//
//  PlacesByCountryTVC.m
//  TopPlaces
//
//  Created by Scott Moen on 7/13/14.
//  Copyright (c) 2014 Scott Moen. All rights reserved.
//

#import "PlacesByCountryTVC.h"
#import "TopPhotosTVC.h"
#import "FlickrFetcher.h"

@interface PlacesByCountryTVC ()

@end

@implementation PlacesByCountryTVC

-(void)viewDidLoad
{
    [self fetchPhotos];
    [super viewDidLoad];
}

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // start the spinner
    dispatch_queue_t fetchQ = dispatch_queue_create("places by country", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:[FlickrFetcher URLforTopPlaces]];
        NSDictionary *dictResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                    options:0
                                                                      error:NULL];
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        for (NSDictionary *place in [dictResults valueForKeyPath:FLICKR_RESULTS_PLACES]) {
            NSArray *placeParts = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
            NSString *country = [placeParts lastObject];
            
            NSMutableArray *placeList = [data objectForKey:country];
            if (!placeList) {
                placeList = [[NSMutableArray alloc] init];
                [data setObject:placeList forKey:country];
            }

            NSUInteger index = [placeList indexOfObject:place
                                          inSortedRange:NSMakeRange(0, [placeList count])
                                                options:NSBinarySearchingInsertionIndex
                                        usingComparator:^(id lhs, id rhs) {
                                            NSString *left = [lhs valueForKeyPath:FLICKR_PLACE_NAME];
                                            NSString *right = [rhs valueForKeyPath:FLICKR_PLACE_NAME];
                                            return [left localizedCaseInsensitiveCompare:right];
                                        }];
            [placeList insertObject:place atIndex:index];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableData = data;
            [self.refreshControl endRefreshing];
        });
    });
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Place Cell" forIndexPath:indexPath];
    NSDictionary *city = [self cityAtIndexPath:indexPath];
    NSArray *cityParts = [[city valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    cell.textLabel.text = [cityParts firstObject];
    cell.detailTextLabel.text = cityParts[1];
    return cell;
}

-(NSDictionary*)cityAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray *cities = [self.tableData objectForKey:[[self sortedKeys] objectAtIndex:indexPath.section]];
    return [cities objectAtIndex:indexPath.row];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TopPhotosTVC *tptvc = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"Top Photos"] && [tptvc isKindOfClass:[TopPhotosTVC class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        tptvc.place = [self cityAtIndexPath:indexPath];
        NSArray *cityParts = [[tptvc.place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
        tptvc.title = [cityParts firstObject];
    }
}

@end
