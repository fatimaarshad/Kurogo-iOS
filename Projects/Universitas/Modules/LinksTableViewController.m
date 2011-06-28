#import "LinksTableViewController.h"
#import "KGOLabel.h"


@implementation LinksTableViewController
@synthesize request;
@synthesize loadingIndicator;
@synthesize loadingView;

- (id)initWithModuleTag: (NSString *) moduleTag
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        
        self.title = NSLocalizedString(@"Links", nil);
        if ((nil == linksArray) || (nil == description))
            [self addLoadingView];
            
    }
    return self;
}

- (void) addLoadingView {
    
    self.loadingView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    loadingView.backgroundColor = [UIColor whiteColor];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [loadingIndicator startAnimating];
    loadingIndicator.center = self.view.center;
    [loadingView addSubview:loadingIndicator];
    [self.view addSubview:loadingView];
}

- (void) removeLoadingView {
    [self.loadingIndicator stopAnimating];
    [self.loadingView removeFromSuperview];
}


- (void)dealloc
{
    [linksArray dealloc];
    [description dealloc];
    self.loadingIndicator = nil;
    self.loadingView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    linksArray = nil;
    description = nil;
    self.loadingIndicator = nil;
    self.loadingView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (nil != linksArray) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (nil != linksArray)
        return [linksArray count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellForLinks";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString * linkTitle = [(NSDictionary *)[linksArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString * linkSubtitle = [(NSDictionary *)[linksArray objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    cell.textLabel.text = linkTitle;
    
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    cell.detailTextLabel.text = linkSubtitle;
    
    UIImageView * accessoryImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kurogo/common/action-external.png"]] autorelease];
    cell.accessoryView = accessoryImageView;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = nil;
    NSString *urlString = [(NSDictionary *)[linksArray objectAtIndex:indexPath.row] objectForKey:@"url"];
    if (urlString) {
        url = [NSURL URLWithString:urlString];
    }
    
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
        
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark KGORequestDelegate

- (void)requestWillTerminate:(KGORequest *)request {
    self.request = nil;
}


- (void)request:(KGORequest *)request didReceiveResult:(id)result {
    self.request = nil;
    
    DLog(@"%@", [result description]);
    
    description = [[result objectForKey:@"description"] retain];
    linksArray = [[result objectForKey:@"links"] retain];
    
    NSString * displayType = [result objectForKey:@"displayType"];
    
    
    if ([displayType isEqualToString:@"list"])
        displayTypeIsList = YES;
    else
        displayTypeIsList = NO;
    
    // Display as TableView
    if (displayTypeIsList == YES) {
        self.tableView.tableHeaderView = [self viewForTableHeader];
        [self.tableView reloadData];
    }

    [self removeLoadingView];
    
}


#pragma mark - Table header


- (UIView *)viewForTableHeader
{
    if (!headerView) {
        // information in header
        
        UIFont *font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyPageSubtitle];
        KGOLabel *nameLabel = [KGOLabel multilineLabelWithText:description font:font width:self.tableView.frame.size.width - 10];
        nameLabel.frame = CGRectMake(10, 10, nameLabel.frame.size.width, nameLabel.frame.size.height);
        
        UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(5, 20, self.tableView.frame.size.width, nameLabel.frame.size.height + 14)] autorelease];
        [header addSubview:nameLabel];
        
        headerView = header;
    }
    
    return headerView;
}

@end
