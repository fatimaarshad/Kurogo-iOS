    //
//  BookmarkedHoursAndLocationsViewController.m
//  Harvard Mobile
//
//  Created by Muhammad J Amjad on 11/29/10.
//  Copyright 2010 ModoLabs Inc. All rights reserved.
//

#import "BookmarkedHoursAndLocationsViewController.h"
#import "MITUIConstants.h"
#import "Library.h"
#import "CoreDataManager.h"
#import "Constants.h"

@implementation BookmarkedHoursAndLocationsViewController
@synthesize listOrMapView;
@synthesize showingMapView;
@synthesize librayLocationsMapView;


NSInteger bookmarkedNameSorted(id lib1, id lib2, void *context);

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		CGRect frame = CGRectMake(0, 0, 400, 44);
        UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15.0];
        //label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"Bookmarked Repositories", @"");
	}
	
	return self;
}

-(void) viewDidLoad {
	
	if (self.showingMapView != YES)
		self.showingMapView = NO;
	
	gpsPressed = NO;
	
	if (nil == _viewTypeButton)
		_viewTypeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Map"
															style:UIBarButtonItemStylePlain 
														   target:self
														   action:@selector(displayTypeChanged:)] autorelease];
	//_viewTypeButton.enabled = NO;										  
	self.navigationItem.rightBarButtonItem = _viewTypeButton;
	
	UIImage *backgroundImage = [UIImage imageNamed:MITImageNameScrollTabBackgroundOpaque];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[backgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    imageView.tag = 1005;
	
	CGFloat footerDisplacementFromTop = self.view.frame.size.height -  NAVIGATION_BAR_HEIGHT -  imageView.frame.size.height;
	imageView.frame = CGRectMake(0, footerDisplacementFromTop, imageView.frame.size.width, imageView.frame.size.height);
    [self.view addSubview:imageView];
    [imageView release];
	
	
	
	//Create the segmented control
	NSArray *itemArray = [NSArray arrayWithObjects: @"All Libraries", @"Open Now", nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
	segmentedControl.tintColor = [UIColor darkGrayColor];
	segmentedControl.frame = CGRectMake(80, footerDisplacementFromTop + 8, 150, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl addTarget:self
	                     action:@selector(pickOne:)
	           forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segmentedControl];
	//[segmentedControl release];
	
	
	UIImage *gpsImage = [UIImage imageNamed:@"maps/map_button_icon_locate.png"];
	NSArray *gpsArray = [NSArray arrayWithObjects: gpsImage, nil];
	gpsButtonControl = [[UISegmentedControl alloc] initWithItems:gpsArray];
	gpsButtonControl.tintColor = [UIColor darkGrayColor];
	gpsButtonControl.frame = CGRectMake(10,footerDisplacementFromTop + 8, 30, 30);
	gpsButtonControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[gpsButtonControl addTarget:self
						 action:@selector(gpsButtonPressed:)
			   forControlEvents:UIControlEventValueChanged];
	
	if (self.showingMapView == YES)
		[self.view addSubview:gpsButtonControl];
	
	//[gpsButtonControl release];
	
	self.listOrMapView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 
																   self.view.frame.size.width,
																   footerDisplacementFromTop)] autorelease];
	
	[self.view addSubview:self.listOrMapView];
	
	
	_tableView = [[UITableView alloc] initWithFrame:self.listOrMapView.frame style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	
	showingOnlyOpen = NO;
	
	[self.listOrMapView addSubview:_tableView];
	
	
	
	NSPredicate *bookmarkPred = [NSPredicate predicateWithFormat:@"isBookmarked == YES"];
	NSArray *tempArray = [CoreDataManager objectsForEntity:LibraryEntityName matchingPredicate:bookmarkPred];
	
	tempArray = [tempArray sortedArrayUsingFunction:bookmarkedNameSorted context:self];
	
	allLibraries = nil;
	allOpenLibraries = nil;
	allLibraries = [[[NSMutableArray alloc] init] retain];
	allOpenLibraries = [[[NSMutableArray alloc] init] retain];
	for(Library * lib in tempArray) {
		[allLibraries addObject:lib];
		
	}
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSPredicate *bookmarkPred = [NSPredicate predicateWithFormat:@"isBookmarked == YES"];
	NSArray *tempArray = [CoreDataManager objectsForEntity:LibraryEntityName matchingPredicate:bookmarkPred];
	
	tempArray = [tempArray sortedArrayUsingFunction:bookmarkedNameSorted context:self];
	
	allLibraries = nil;
	allLibraries = [[[NSMutableArray alloc] init] retain];
	for(Library * lib in tempArray) {
		[allLibraries addObject:lib];
	}
	
	[_tableView reloadData];
}



//Action method executes when user touches the button
- (void) pickOne:(id)sender{
	//UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	[segmentedControl selectedSegmentIndex];
	
	showingOnlyOpen = !showingOnlyOpen;
	[_tableView reloadData];
	
	
	if (showingMapView == YES) {
		
		if (nil != librayLocationsMapView) {
			if (showingOnlyOpen == NO)
				[librayLocationsMapView setAllLibraryLocations:allLibraries];
			
			else {
				[librayLocationsMapView setAllLibraryLocations:allOpenLibraries];
			}
			
			[librayLocationsMapView viewWillAppear:YES];
		}
	}
	
	//label.text = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
} 


-(void)displayTypeChanged:(id)sender {
	
	if([_viewTypeButton.title isEqualToString:@"Map"]) {
		[self setMapViewMode:YES animated:YES];
		showingMapView = YES;
	}
	else if ([_viewTypeButton.title isEqualToString:@"List"]) {
		[self setMapViewMode:NO animated:YES];
		showingMapView = NO;
	}
	
	if (self.showingMapView == YES)
		[self.view addSubview:gpsButtonControl];
	
	else {
		
		[gpsButtonControl removeFromSuperview];
		[gpsButtonControl retain];
	}
}

-(void) gpsButtonPressed:(id)sender {
	UISegmentedControl *segmentedController = (UISegmentedControl *)sender;
	segmentedController.selectedSegmentIndex = -1;
	
	if (showingMapView == YES)
	{
		//self.librayLocationsMapView.mapView.showsUserLocation = !self.librayLocationsMapView.mapView.showsUserLocation;
		
		if (!self.librayLocationsMapView.mapView.showsUserLocation) {	
			
			
			BOOL successful = [self.librayLocationsMapView mapView:self.librayLocationsMapView.mapView 
											 didUpdateUserLocation:self.librayLocationsMapView.mapView.userLocation];
			
			if (successful == YES)
				self.librayLocationsMapView.mapView.showsUserLocation = YES;
			
		}
		
		else {	
			self.librayLocationsMapView.mapView.showsUserLocation = NO;
			self.librayLocationsMapView.mapView.region = [self.librayLocationsMapView 
														  regionForAnnotations:self.librayLocationsMapView.mapView.annotations];
			
			
		}
	}		
	
	gpsPressed = !gpsPressed;
}


// set the view to either map or list mode
-(void) setMapViewMode:(BOOL)showMap animated:(BOOL)animated {
	//NSLog(@"map is showing=%i", _mapShowing);
	if (showMap == YES) {
		if (showingMapView)
			return;
	}
	
	// flip to the correct view. 
	if (animated) {
		[UIView beginAnimations:@"flip" context:nil];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.listOrMapView cache:NO];
	}
	
	if (!showMap) {
		
		if (nil != self.librayLocationsMapView)
			[self.librayLocationsMapView.view removeFromSuperview];
		
		[self.listOrMapView addSubview:_tableView];
		[_tableView reloadData];
		self.librayLocationsMapView = nil;
		_viewTypeButton.title = @"Map";
		
		
	} else {
		[_tableView removeFromSuperview];
		
		if (nil == librayLocationsMapView) {
			librayLocationsMapView = [[LibraryLocationsMapViewController alloc] initWithMapViewFrame:self.listOrMapView.frame];
			
		}
		
		//librayLocationsMapView.parentViewController = self;
		librayLocationsMapView.view.frame = self.listOrMapView.frame;
		[self.listOrMapView addSubview:librayLocationsMapView.view];
		
		if (showingOnlyOpen == NO)
			[librayLocationsMapView setAllLibraryLocations:allLibraries];
		
		else {
			[librayLocationsMapView setAllLibraryLocations:allOpenLibraries];
		}
		
		[librayLocationsMapView viewWillAppear:YES];
		_viewTypeButton.title = @"List";
		
	}
	
	if(animated) {
		[UIView commitAnimations];
	}
	
}



/*
 - (void)buttonPressed:(id)sender {
 UIButton *pressedButton = (UIButton *)sender;
 if (pressedButton.tag == SEARCH_BUTTON_TAG) {
 [self showSearchBar];
 } else {
 [self reloadView:pressedButton.tag];
 }
 }
 */


/*- (void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Release any cached data, images, etc that aren't in use.
 }*/

- (void)viewDidUnload {
    [super viewDidUnload];
	
    
	// Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	//return 6;
	int count = 0;
	
	if (showingOnlyOpen == NO) {
		if (nil != allLibraries)
			count = [allLibraries count];
	}
	else {
		if (nil != allOpenLibraries)
			count = [allOpenLibraries count];
	}
	
	
	return count;
	
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 ShuttleStop *aStop = nil;
 if(nil != self.route && self.route.stops.count > indexPath.row) {
 aStop = [self.route.stops objectAtIndex:indexPath.row];
 }
 
 
 CGSize constraintSize = CGSizeMake(280.0f, 2009.0f);
 NSString* cellText = @"A"; // just something to guarantee one line
 UIFont* cellFont = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
 CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
 
 if (aStop.upcoming)
 labelSize.height += 5.0f;
 
 return labelSize.height + 20.0f;
 }
 */


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *optionsForMainViewTableStringConstant = @"listViewCell";
	UITableViewCell *cell = nil;
	
	
	cell = [tableView dequeueReusableCellWithIdentifier:optionsForMainViewTableStringConstant];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:optionsForMainViewTableStringConstant] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	Library * lib; 
	if (showingOnlyOpen == NO) {
		lib = [allLibraries objectAtIndex:indexPath.section];
		
		if (nil != allLibraries)
			cell.textLabel.text = lib.name;
	}
	
	else {
		lib = [allOpenLibraries objectAtIndex:indexPath.section];
		
		if (nil != allOpenLibraries)
			cell.textLabel.text = lib.name;
	}
	
	
    return cell;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	
	NSMutableArray *tempLibraries;
	NSMutableArray *tempIndexArray = [NSMutableArray array];
	
	
	if (showingOnlyOpen == NO)
		tempLibraries = allLibraries;
	
	else {
		tempLibraries = allOpenLibraries;
	}
	
	
	for(Library *lib in tempLibraries) {
		if (![tempIndexArray containsObject:[lib.name substringToIndex:1]])
			[tempIndexArray addObject:[lib.name substringToIndex:1]];		
	}
	
	NSArray *indexArray = (NSArray *)tempIndexArray;
	
	return indexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSMutableArray *tempLibraries;
	
	if (showingOnlyOpen == NO)
		tempLibraries = allLibraries;
	
	else {
		tempLibraries = allOpenLibraries;
	}
	int ind = 0;
	
	for(Library *lib in tempLibraries) {
		if ([[lib.name substringToIndex:1] isEqualToString:title])
			break;
		ind++;
	}
	
	return ind;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	LibraryDetailViewController *vc = [[LibraryDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
	NSArray * tempArray;
	
	if (showingOnlyOpen == NO)
		tempArray = allLibraries;
	else {
		tempArray = allOpenLibraries;
	}
	
	Library * lib = (Library *) [tempArray objectAtIndex:indexPath.section];
	vc.lib = [lib retain];
	vc.otherLibraries = [tempArray retain];
	vc.currentlyDisplayingLibraryAtIndex = indexPath.section;
	vc.title = @"Library Detail";
	
	NSString * libOrArchive;
	
	if ([lib.type isEqualToString:@"archive"])
		libOrArchive = @"archivedetail";
	
	else {
		libOrArchive = @"libdetail";
	}

	apiRequest = [[JSONAPIRequest alloc] initWithJSONAPIDelegate:vc];
	if ([apiRequest requestObjectFromModule:@"libraries" 
									command:libOrArchive
								 parameters:[NSDictionary dictionaryWithObjectsAndKeys:lib.identityTag, @"id", lib.name, @"name", nil]])
	{
		[self.navigationController pushViewController:vc animated:YES];
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
															message:@"Could not connect to the server" 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	

	[vc release];
	
}


#pragma mark -
#pragma mark JSONAPIRequest Delegate function 

- (void)request:(JSONAPIRequest *)request jsonLoaded:(id)result {
	
	NSArray *resultArray = (NSArray *)result;
	
	if ([result count]){
		allLibraries = nil;
		allOpenLibraries = nil;
		allLibraries = [[[NSMutableArray alloc] init] retain];
		allOpenLibraries = [[[NSMutableArray alloc] init] retain];
	}
	
	for (int index=0; index < [result count]; index++) {
		NSDictionary *libraryDictionary = [resultArray objectAtIndex:index];
		
		
		NSString * name = [libraryDictionary objectForKey:@"name"];
		//NSString * identityTag = [libraryDictionary objectForKey:@"id"];		
		NSString * type = [libraryDictionary objectForKey:@"type"];
		
		NSString *isOpenNow = [libraryDictionary objectForKey:@"isOpenNow"];
		
		BOOL isOpen = NO;
		if ([isOpenNow isEqualToString:@"YES"])
			isOpen = YES;
		
		
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"name == %@ AND type == %@ AND isBookmarked == YES", name, type];
		Library *alreadyInDB = [[CoreDataManager objectsForEntity:LibraryEntityName matchingPredicate:pred] lastObject];

		if (nil != alreadyInDB){

			[allLibraries addObject:alreadyInDB];
		
		if (isOpen)
			[allOpenLibraries addObject:alreadyInDB];
		}
	}
	NSArray * tempArray = [allLibraries sortedArrayUsingFunction:bookmarkedNameSorted context:self];
	
	allLibraries = nil;
	allLibraries = [[NSMutableArray alloc] init];
	for(Library * lib in tempArray) {
		[allLibraries addObject:lib];		
	}
	tempArray = nil;
	tempArray = [allOpenLibraries sortedArrayUsingFunction:bookmarkedNameSorted context:self];
	allOpenLibraries = nil;
	allOpenLibraries = [[NSMutableArray alloc] init];
	for(Library * lib in tempArray) {
		[allOpenLibraries addObject:lib];		
	}
	
	[allLibraries retain];
	[allOpenLibraries retain];
	
	[CoreDataManager saveData];
	
	
	[_tableView reloadData];
	//[parentViewController removeLoadingIndicator];
}

- (BOOL)request:(JSONAPIRequest *)request shouldDisplayAlertForError:(NSError *)error {
	
    return YES;
}

- (void)request:(JSONAPIRequest *)request handleConnectionError:(NSError *)error {
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:@"Could not retrieve Libraries/Archives" 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


NSInteger bookmarkedNameSorted(id lib1, id lib2, void *context) {
	
	Library * library1 = (Library *)lib1;
	Library * library2 = (Library *)lib2;
	
	return [library1.name compare:library2.name];
}	


@end