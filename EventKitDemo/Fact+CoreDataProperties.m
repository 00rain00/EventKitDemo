//
//  Fact+CoreDataProperties.m
//  EventKitDemo
//
//  Created by YULIN CAI on 26/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "Fact+CoreDataProperties.h"

@implementation Fact (CoreDataProperties)

+ (NSFetchRequest<Fact *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Fact"];
}

@dynamic time;
@dynamic factKey;
@dynamic factValue;

@end
