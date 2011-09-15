#import "PersonContact.h"
#import "KGOPerson.h"
#import "Foundation+KGOAdditions.h"
#import "CoreDataManager.h"

@implementation PersonContact 

@dynamic person;

+ (NSArray *)directoryContacts 
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"person = nil"];
    return [[CoreDataManager sharedManager] objectsForEntity:PersonContactEntityName matchingPredicate:pred];
}

+ (PersonContact *)personContactWithDictionary:(NSDictionary *)aDict type:(NSString *)aType {
    PersonContact *contact = [[CoreDataManager sharedManager] insertNewObjectForEntityForName:PersonContactEntityName];
    contact.type = aType;
    contact.url = [aDict nonemptyStringForKey:@"url"];
    contact.title = [aDict nonemptyStringForKey:@"title"];
    contact.subtitle = [aDict nonemptyStringForKey:@"subtitle"];
    contact.group = [aDict nonemptyStringForKey:@"group"];
    return contact;
}

- (NSDictionary *)dictionary {
    return [self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"subtitle", @"title", @"type", @"identifier", nil]];
}

@end
