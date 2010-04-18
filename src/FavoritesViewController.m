//
//  FavoritesViewController.m
//
//  Created by thomas dobranowski on 12/04/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Favorite.h"
#import "Model.h"
#import "Hotspot.h"
#import "HotspotInfosViewController.h"

@implementation FavoritesViewController

@synthesize favoritesArray;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Set the title.
	self.title = @"Favorites";
	// Set up the buttons.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	favoritesArray=[[NSMutableArray alloc] init];
	[self setFavoritesArray:[NSMutableArray arrayWithArray:[Favorite findAll]]];
	
}

- (void)viewDidUnload { 
	self.favoritesArray = nil;
	
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	favoritesArray=[[NSMutableArray alloc] init];
	[self setFavoritesArray:[NSMutableArray arrayWithArray:[Favorite findAll]]];
	[[self tableView]reloadData];
}
- (void)dealloc { 
	
	[favoritesArray release]; 
	[super dealloc];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [favoritesArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	return 60.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// A date formatter for the time stamp static 
	NSDateFormatter *dateFormatter = nil; 
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	static NSString *CellIdentifier = @"identifier";
	// Dequeue or create a new cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
	} 
	
	Favorite *favorite = (Favorite *)[favoritesArray objectAtIndex:indexPath.row];
	
	
	NSString *identifier=favorite.identifier;
	NSPredicate *predicate = identifier
	? [NSPredicate predicateWithFormat:@"identifier == %@", favorite.identifier]
	: nil;
	id entity = [[Model shared] findFirstObjectForEntityForName:@"Hotspot" 
													  predicate:predicate 
													   sortedBy:nil];
	if(entity!=nil)
	{
		Hotspot *hotspot=entity;
		cell.detailTextLabel.text=[hotspot streetAddress];
	}
	else {
	    cell.detailTextLabel.text=@"This hotspot has been removed!";
		cell.detailTextLabel.textColor = [UIColor redColor];
	}
	
	cell.textLabel.text = [favorite name];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	Favorite *favorite = (Favorite *)[favoritesArray objectAtIndex:indexPath.row];
	NSString *identifier=favorite.identifier;
	NSPredicate *predicate = identifier
	? [NSPredicate predicateWithFormat:@"identifier == %@", favorite.identifier]
	: nil;
	id entity = [[Model shared] findFirstObjectForEntityForName:@"Hotspot" 
													  predicate:predicate 
													   sortedBy:nil];
	if(entity!=nil)
	{
		Hotspot *hotspot=entity;
		HotspotInfosViewController *infosController = [[[HotspotInfosViewController alloc] initWithNibName:@"HotspotInfosViewController" bundle:nil] autorelease];
		infosController.hotspot = hotspot;
		
		[infosController changeImageLeftBarButtonItem:@"btn-back-favorites"];
		[self presentModalViewController:infosController animated:YES];
	}
	
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        Favorite *favorite = (Favorite *)[favoritesArray objectAtIndex:indexPath.row];
		
		[[Model shared] deleteObject:favorite];
		
        [favoritesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[[Model shared] save];
		
    }   
}

@end


