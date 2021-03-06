//
//  ExampleTableViewController.m
//  Example
//
//  Created by Andy Smart on 20/08/2011.
//  Copyright 2011 Andy Smart. All rights reserved.
//

#import "ExampleTableViewController.h"

@interface ExampleTableViewController()
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) AJSiTunesAPI *iTunesAPIController;
@end

@implementation ExampleTableViewController
@synthesize iTunesAPIController = _iTunesAPIController;
@synthesize searchResults = _searchResults;
@synthesize loadingSpinner = _loadingSpinner;

- (void) dealloc {
    
    [_loadingSpinner release], _loadingSpinner = nil;
    [_searchResults release], _searchResults = nil;
    [_iTunesAPIController release], _iTunesAPIController = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load with a default search
    
    self.iTunesAPIController = [[[AJSiTunesAPI alloc] init] autorelease];
    
    __block typeof(self) blockSelf = self;
    
    [self.iTunesAPIController searchMediaWithType:kAJSiTunesAPIMediaTypeMusic
                                       searchTerm:@"Jack Johnson"
                                      countryCode:@"GB"
                                            limit:50
                                  completionBlock:^(NSArray *results) {
                                    
                                      blockSelf.searchResults = [NSArray arrayWithArray:results];
                                      
                                      [blockSelf.tableView beginUpdates];
                                      [blockSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                    withRowAnimation:UITableViewRowAnimationFade];
                                      [blockSelf.tableView endUpdates];
                                      
                                      [blockSelf.loadingSpinner stopAnimating];
                                      blockSelf.navigationItem.title = @"Search Results";
                                      
                                  } failureBlock:^(NSError *error) {
                                      
                                      UIAlertView *alert = [[UIAlertView alloc]
                                                            initWithTitle:@"An Error occurred"
                                                            message:[NSString stringWithFormat:@"Error: %@", error]
                                                            delegate:nil
                                                            cancelButtonTitle:@"Oooops"
                                                            otherButtonTitles:nil];
                                      [alert show];
                                      [alert release];
                                      
                                      [blockSelf.loadingSpinner stopAnimating];
                                      blockSelf.navigationItem.title = @"Error";
                                  }];
    
    //Show a loading indicator top right
    
    self.loadingSpinner = [[[UIActivityIndicatorView alloc] init] autorelease];
    self.loadingSpinner.frame = CGRectMake(0, 0, 20, 20);
    self.loadingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] 
                                  initWithCustomView:self.loadingSpinner];

    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
    [self.loadingSpinner startAnimating];
    self.navigationItem.title = @"Loading...";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleSubtitle 
                 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    AJSiTunesResult *item = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.artistName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
