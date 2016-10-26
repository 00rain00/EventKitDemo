//
//  Fact+CoreDataProperties.h
//  EventKitDemo
//
//  Created by YULIN CAI on 26/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "Fact+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Fact (CoreDataProperties)

+ (NSFetchRequest<Fact *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, copy) NSString *factKey;
@property (nullable, nonatomic, retain) id factValue;

@end

NS_ASSUME_NONNULL_END
