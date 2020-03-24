//
//  Movie.h
//  ObjectiveCProject
//
//  Created by Rodrigo Giglio on 17/03/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonnull, strong, nonatomic) NSString *title;
@property (nonnull, strong, nonatomic) NSString *overview;
@property (nonnull, strong, nonatomic) NSNumber *rating;
@property (nullable, strong, nonatomic) NSString *imageUrl;

-(nonnull id) initWithDictionary:(nonnull NSDictionary *) dictionary;

@end
