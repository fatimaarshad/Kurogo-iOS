//
//  LibrariesMainViewController.m
//  Harvard Mobile
//
//  Created by Muhammad J Amjad on 11/15/10.
//  Copyright 2010 ModoLabs Inc. All rights reserved.
//

#import "LibrariesMainViewController.h"
#import "MITUIConstants.h"
#import "ModoSearchBar.h"
#import "MITSearchDisplayController.h"
#import "HoursAndLocationsViewController.h"
#import "LibrariesSearchViewController.h"
#import "CoreDataManager.h"
#import "BookmarkedLibItemListView.h"
#import "LibraryAdvancedSearch.h"
#import "MobileResearchLinksViewController.h"
#import "JSONAPIRequest.h"

@implementation LibrariesMainViewController
@synthesize searchTerms, searchController;
@synthesize searchBar = theSearchBar, tableView = _tableView;


-(void) setUpLayOut {
	
	if (nil == theSearchBar)
		theSearchBar = [[ModoSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT)];
	
	theSearchBar.tintColor = SEARCH_BAR_TINT_COLOR;
	theSearchBar.placeholder = @"HOLLIS keyword search";
	theSearchBar.showsBookmarkButton = NO; // use custom bookmark button
	
	theSearchBar.text = @"";
	
	if (nil == searchController)
		self.searchController = [[[MITSearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self] autorelease];
	
	self.searchController.delegate = self;
	self.searchController.searchResultsDelegate = self;
	self.searchController.searchResultsDataSource = self;
	
    [self.view addSubview:theSearchBar];
	
    CGRect frame = CGRectMake(0.0, theSearchBar.frame.size.height,
                              self.view.frame.size.width,
                              self.view.frame.size.height - theSearchBar.frame.size.height);
	
	if (nil != self.tableView)
		[self.tableView removeFromSuperview];
	
	self.tableView = nil;
	
	self.tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
	
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	[self.tableView applyStandardColors];
    
	static NSString *searchHints = @"";
	
	UIFont *hintsFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	CGSize labelSize = [searchHints sizeWithFont:hintsFont
							   constrainedToSize:self.tableView.frame.size
								   lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel *hintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, labelSize.width, labelSize.height + 5.0)];
	hintsLabel.numberOfLines = 0;
	hintsLabel.backgroundColor = [UIColor clearColor];
	hintsLabel.lineBreakMode = UILineBreakModeWordWrap;
	hintsLabel.font = hintsFont;
	hintsLabel.text = searchHints;	
    hintsLabel.textColor = [UIColor colorWithHexString:@"#404040"];
    UIView *hintsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, labelSize.width, labelSize.height + 10.0)];
	[hintsContainer addSubview:hintsLabel];
	[hintsLabel release];
	
    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 
																			   self.tableView.frame.size.width, 
																			   hintsContainer.frame.size.height)] autorelease];
	[self.tableView.tableHeaderView addSubview:hintsContainer];
	[hintsContainer release];
	
	[self.view addSubview:self.tableView];
    [self.searchBar addDropShadow];
	
	// add our own bookmark button item since we are not using the default
	// bookmark button of the UISearchBar
    // TODO: don't hard code this frame
	
	_bookmarkButton = nil;
	if (nil == _bookmarkButton) {
		_bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake(282, 8, 32, 28)];
		[_bookmarkButton setImage:[UIImage imageNamed:@"global/searchfield_star.png"] forState:UIControlStateNormal];
	}
	[self.view addSubview:_bookmarkButton];
	[_bookmarkButton addTarget:self action:@selector(bookmarkItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	
	// set up tableView options
	
	NSString * option1 = @"Library Locations and Hours";
	NSString * option2 = @"Archive Locations and Hours";	
	mainViewTableOptions1 = [[NSArray alloc] initWithObjects: option1, option2, nil];
	
	NSString * option3 = @"Advanced HOLLIS Search";
	NSString * option4 = @"Mobile Research Links";
	NSString * option5 = @"Ask a Librarian";
	mainViewTableOptions2 = [[NSArray alloc] initWithObjects: option3, option4, option5, nil];
}

- (void)setupBookmarks {
	
	hasBookmarkedLibraries = NO;
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"isBookmarked == YES"];
    [bookmarkedLibraries release];
	bookmarkedLibraries = [[CoreDataManager objectsForEntity:LibraryEntityName matchingPredicate:pred] retain];
	
	if ([bookmarkedLibraries count] > 0)
		hasBookmarkedLibraries = YES;
	
	
	if (hasBookmarkedLibraries == NO) {
		bookmarkedLibraries = [[NSArray alloc] initWithObjects: nil];
		//[self hideToolBar];
	}
	
	NSPredicate *predItem = [NSPredicate predicateWithFormat:@"isBookmarked == YES"];
    [bookmarkedItems release];
	bookmarkedItems = [[CoreDataManager objectsForEntity:LibraryItemEntityName matchingPredicate:predItem] retain];
	
	if ([bookmarkedItems count] > 0)
		hasBookmarkedItems = YES;
	
	if (hasBookmarkedItems == NO) {
		bookmarkedItems = [[NSArray alloc] initWithObjects: nil];
		[self hideToolBar];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setUpLayOut];
	[self setupBookmarks];
}	

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[searchController unfocusSearchBarAnimated:YES];
	[searchController hideSearchOverlayAnimated:YES];
    [self setupBookmarks];

	[self.tableView reloadData];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.searchController = nil;
    self.searchBar = nil;
	
	self.tableView = nil;
	
    [_bookmarkButton release];
	_bookmarkButton = nil;
	
    [mainViewTableOptions1 release];
	mainViewTableOptions1 = nil;

    [mainViewTableOptions2 release];
	mainViewTableOptions2 = nil;
	
    [bookmarkedLibraries release];
	bookmarkedLibraries = nil;
    
    [bookmarkedItems release];
    bookmarkedItems = nil;
	
}


- (void)dealloc {
	self.searchController = nil;
	
    self.tableView = nil;
    self.searchTerms = nil;
    self.searchBar = nil;

    [_bookmarkButton release];
    [mainViewTableOptions1 release];
    [mainViewTableOptions2 release];
    
    [bookmarkedLibraries release];
    [bookmarkedItems release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)bookmarkItemButtonClicked:(UIButton *)sender {
	
	BookmarkedLibItemListView *vc = [[BookmarkedLibItemListView alloc] initWithStyle:UITableViewStylePlain];
	vc.title = @"Bookmarked Items";
	
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];	
}

- (void)setupSearchController {
    if (!self.searchController) {
        self.searchController = [[[MITSearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self] autorelease];
        self.searchController.delegate = self;
    }
}

- (void)hideToolBar {
    [UIView beginAnimations:@"searching" context:nil];
    [UIView setAnimationDuration:0.4];
    _bookmarkButton.alpha = 0.0;
        theSearchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, NAVIGATION_BAR_HEIGHT);
       // _toolBar.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)restoreToolBar {
    [theSearchBar setShowsCancelButton:NO animated:YES];
    [UIView beginAnimations:@"searching" context:nil];
    [UIView setAnimationDuration:0.4];
	
	if (hasBookmarkedItems)
		_bookmarkButton.alpha = 1.0;

    [UIView commitAnimations];
	
    CGRect frame = _bookmarkButton.frame;
    frame.origin.x = theSearchBar.frame.size.width - frame.size.width - 7;
    _bookmarkButton.frame = frame;
}

#pragma mark -
#pragma mark Search methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self restoreToolBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[_bookmarkButton removeFromSuperview];
	
	self.searchTerms = searchBar.text;
	
	LibrariesSearchViewController *vc = [[LibrariesSearchViewController alloc] initWithViewController: self];
	vc.title = @"Search Results";
	
	JSONAPIRequest *api = [JSONAPIRequest requestWithJSONAPIDelegate:vc];
	BOOL requestWasDispatched = [api requestObjectFromModule:@"libraries"
                                                     command:@"search"
                                                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:self.searchTerms, @"keywords", nil]];
	
    if (requestWasDispatched) {
		vc.searchTerms = searchBar.text;
		[self.navigationController pushViewController:vc animated:YES];
    }
	
	[vc release];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[self setupSearchController]; // in case we got rid of it from a memory warning
    [self hideToolBar];
}

/*
- (void)presentSearchResults:(NSArray *)theSearchResults {
    self.searchResults = theSearchResults;
    self.searchController.searchResultsTableView.frame = self.tableView.frame;
    [self.view addSubview:self.searchController.searchResultsTableView];
    [self.searchBar addDropShadow];
    [self.searchController.searchResultsTableView reloadData];
}
*/


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int bookmarkRowCount = 0;
	if (hasBookmarkedLibraries == YES)
		bookmarkRowCount = 1;
	
	if (section == 0)
		return [mainViewTableOptions1 count] + bookmarkRowCount;
	
	else if (section == 1){
		return [mainViewTableOptions2 count];
	}
	else return 0;

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *optionsForMainViewTableStringConstant = @"InfoCell";
	UITableViewCell *cell = nil;
	

	cell = [tableView dequeueReusableCellWithIdentifier:optionsForMainViewTableStringConstant];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:optionsForMainViewTableStringConstant] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		
		//cell.detailTextLabel.text = @" "; // if this is empty textlabel will be bottom aligned

	int section = indexPath.section;
	int row = indexPath.row;
	
	if (section == 0) {
		if ([bookmarkedLibraries count] > 0) {
			if (row == 0) {
				cell.textLabel.text = @"My Bookmarked Libraries";
			}
			else {
				cell.textLabel.text = (NSString *)[mainViewTableOptions1 objectAtIndex:row-1];
			}

		}
		else {
			cell.textLabel.text = (NSString *)[mainViewTableOptions1 objectAtIndex:row];
		}
	}
	else if (section == 1) {
		cell.textLabel.text = (NSString *)[mainViewTableOptions2 objectAtIndex:row];
		
		if (row == 2) { // ask a librarian
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = [UIImageView accessoryViewWithMITType:MITAccessoryViewExternal];
		}
	}
		
	

	return cell;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return GROUPED_SECTION_HEADER_HEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		
		if (((indexPath.row == 0) && (hasBookmarkedLibraries == NO)) ||
			((indexPath.row == 1) && (hasBookmarkedLibraries == YES)))
		{
			HoursAndLocationsViewController *vc = [[HoursAndLocationsViewController alloc] init];
            vc.typeOfRepo = @"Libraries";
			vc.title = @"Libraries";
            vc.showBookmarks = NO;
            [self.navigationController pushViewController:vc animated:YES];
			[vc release];
		}
		else if (((indexPath.row == 1) && (hasBookmarkedLibraries == NO)) ||
						((indexPath.row == 2) && (hasBookmarkedLibraries == YES)))
		{
			HoursAndLocationsViewController *vc = [[HoursAndLocationsViewController alloc] init];
			vc.showArchives = YES;
            vc.showBookmarks = NO;
            vc.typeOfRepo = @"Archives";
			vc.title = @"Archives";
            [self.navigationController pushViewController:vc animated:YES];
			[vc release];
		}
		
		else if ((indexPath.row == 0) && (hasBookmarkedLibraries == YES)){
			
            HoursAndLocationsViewController *vc = [[HoursAndLocationsViewController alloc] init];
            vc.showBookmarks = YES;
            // TODO: let VC use its own showBookmarks property to choose display title
			vc.title = @"Bookmarked Libraries";
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
		}
	}
	
	else if (indexPath.section == 1){
		
		if (indexPath.row == 0){ // advanced hollis search
			
			LibraryAdvancedSearch * vc = [[LibraryAdvancedSearch alloc] initWithNibName:@"LibraryAdvancedSearch" 
																				 bundle:nil
																			   keywords:@""
                                                                                  title:@""
                                                                                 author:@""
                                                                      englishOnlySwitch:false
                                                                            formatIndex:0
                                                                          locationIndex:0];
			
			vc.title = @"Advanced Search";
            [self.navigationController pushViewController:vc animated:YES];
			[vc release];
		}
		else if (indexPath.row == 1){ // mobile research links
			
			MobileResearchLinksViewController * vc = [[MobileResearchLinksViewController alloc] init];
			vc.title = @"Mobile Research Links";
			
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			
		}
		else if (indexPath.row == 2) { // ask a librarian
			NSString *url = @"http://asklib.hcl.harvard.edu/mobile.php";
			
			NSURL *askALibrarianURL = [NSURL URLWithString:url];
			if (askALibrarianURL && [[UIApplication sharedApplication] canOpenURL:askALibrarianURL]) {
				[[UIApplication sharedApplication] openURL:askALibrarianURL];
			}
			
		}
				 
	}

}


@end
