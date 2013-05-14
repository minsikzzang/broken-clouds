//
//  IFObject.m
//  weather-shot
//
//  Created by Min Kim on 4/25/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IFObject<NSObject>

/*!
 @method
 @abstract
 Returns the number of properties on this `LSLegacyChannel`.
 */
- (NSUInteger)count;
/*!
 @method
 @abstract
 Returns a property on this `LSLegacyChannel`.
 
 @param aKey        name of the property to return
 */
- (id)objectForKey:(id)aKey;
/*!
 @method
 @abstract
 Returns an enumerator of the property naems on this `LSLegacyChannel`.
 */
- (NSEnumerator *)keyEnumerator;
/*!
 @method
 @abstract
 Removes a property on this `LSLegacyChannel`.
 
 @param aKey        name of the property to remove
 */
- (void)removeObjectForKey:(id)aKey;
/*!
 @method
 @abstract
 Sets the value of a property on this `LSLegacyChannel`.
 
 @param anObject    the new value of the property
 @param aKey        name of the property to set
 */
- (void)setObject:(id)anObject forKey:(id)aKey;

@end

@interface IFObject : NSMutableDictionary<IFObject>

+ (id)ifObjectWrappingObject:(id)originalObject;


@end
