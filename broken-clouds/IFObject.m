//
//  IFObject.m
//  weather-shot
//
//  Created by Min Kim on 4/25/13.
//  Copyright (c) 2013 min kim. All rights reserved.
//

#import "IFObject.h"

#import <objc/runtime.h>

static NSString *const kIFObjectKey = @"LSObjectKey";

// used internally by the category impl
typedef enum _SelectorInferredImplType {
  SelectorInferredImplTypeNone  = 0,
  SelectorInferredImplTypeGet = 1,
  SelectorInferredImplTypeSet = 2
} SelectorInferredImplType;

// internal-only wrapper
@interface IFObjectArray : NSMutableArray

- (id)initWrappingArray:(NSArray *)otherArray;
- (id)lsObjectifyAtIndex:(NSUInteger)index;
- (void)lsObjectifyAll;

@end

@interface IFObject ()

- (id)initWrappingDictionary:(NSDictionary *)otherDictionary;
- (void)lsObjectifyAll;
- (id)lsObjectifyAtKey:(id)key;

+ (id)ifObjectWrappingObject:(id)originalObject;
+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel;
+ (BOOL)isProtocolImplementationInferable:(Protocol *)protocol
                    checkLSObjectAdoption:(BOOL)checkAdoption;

@end

@implementation IFObject {
  NSMutableDictionary *_jsonObject;
}

- (id)initWrappingDictionary:(NSDictionary *)jsonObject {
  self = [super init];
  if (self) {
    if ([jsonObject isKindOfClass:[IFObject class]]) {
      // in this case, we prefer to return the original object,
      // rather than allocate a wrapper
      
      // we are about to return this, better make it the caller's
      [jsonObject retain];
      
      // we don't need self after all
      [self release];
      
      // no wrapper needed, returning the object that was provided
      return (IFObject *)jsonObject;
    } else {
      _jsonObject = [[NSMutableDictionary dictionaryWithDictionary:jsonObject]
                     retain];
    }
  }
  return self;
}

- (void)dealloc {
  [_jsonObject release];
  [super dealloc];
}

#pragma mark -
#pragma mark Public Members

+ (NSMutableDictionary<IFObject>*)lsObject {
  return [IFObject lsObjectWrappingDictionary:[NSMutableDictionary dictionary]];
}

+ (NSMutableDictionary<IFObject>*)lsObjectWrappingDictionary:(NSDictionary*)jsonDictionary {
  return [IFObject ifObjectWrappingObject:jsonDictionary];
}

+ (BOOL)isLSObjectID:(id<IFObject>)anObject sameAs:(id<IFObject>)anotherObject {
  if (anObject != nil &&
      anObject == anotherObject) {
    return YES;
  }
  id anID = [anObject objectForKey:@"id"];
  id anotherID = [anotherObject objectForKey:@"id"];
  if ([anID isKindOfClass:[NSString class]] &&
      [anotherID isKindOfClass:[NSString class]]) {
    return [(NSString*)anID isEqualToString:anotherID];
  }
  return NO;
}

#pragma mark -
#pragma mark NSObject overrides

// make the respondsToSelector method do the right thing for the selectors we handle
- (BOOL)respondsToSelector:(SEL)sel {
  return  [super respondsToSelector:sel] ||
  ([IFObject inferredImplTypeForSelector:sel] != SelectorInferredImplTypeNone);
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
  return  [super conformsToProtocol:protocol] ||
  ([IFObject isProtocolImplementationInferable:protocol
                         checkLSObjectAdoption:YES]);
}

// returns the signature for the method that we will actually invoke
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  SEL alternateSelector = sel;
  
  // if we should forward, to where?
  switch ([IFObject inferredImplTypeForSelector:sel]) {
    case SelectorInferredImplTypeGet:
      alternateSelector = @selector(objectForKey:);
      break;
    case SelectorInferredImplTypeSet:
      alternateSelector = @selector(setObject:forKey:);
      break;
    case SelectorInferredImplTypeNone:
    default:
      break;
  }
  
  return [super methodSignatureForSelector:alternateSelector];
}

// forwards otherwise missing selectors that match the LSObject convention
- (void)forwardInvocation:(NSInvocation *)invocation {
  // if we should forward, to where?
  switch ([IFObject inferredImplTypeForSelector:[invocation selector]]) {
    case SelectorInferredImplTypeGet: {
      // property getter impl uses the selector name as an argument...
      NSString *propertyName = NSStringFromSelector([invocation selector]);
      [invocation setArgument:&propertyName atIndex:2];
      //... to the replacement method objectForKey:
      invocation.selector = @selector(objectForKey:);
      [invocation invokeWithTarget:self];
      break;
    }
    case SelectorInferredImplTypeSet: {
      // property setter impl uses the selector name as an argument...
      NSMutableString *propertyName = [NSMutableString stringWithString:NSStringFromSelector([invocation selector])];
      // remove 'set' and trailing ':', and lowercase the new first character
      [propertyName deleteCharactersInRange:NSMakeRange(0, 3)];                       // "set"
      [propertyName deleteCharactersInRange:NSMakeRange(propertyName.length - 1, 1)]; // ":"
      
      NSString *firstChar = [[propertyName substringWithRange:NSMakeRange(0,1)] lowercaseString];
      [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
      // the object argument is already in the right place (2), but we need to set the key argument
      [invocation setArgument:&propertyName atIndex:3];
      // and replace the missing method with setObject:forKey:
      invocation.selector = @selector(setObject:forKey:);
      [invocation invokeWithTarget:self];
      break;
    }
    case SelectorInferredImplTypeNone:
    default:
      [super forwardInvocation:invocation];
      return;
  }
}

- (id)lsObjectifyAtKey:(id)key {
  id object = [_jsonObject objectForKey:key];
  // make certain it is FBObjectGraph-ified
  id possibleReplacement = [IFObject ifObjectWrappingObject:object];
  if (object != possibleReplacement) {
    // and if not-yet, replace the original with the wrapped object
    [_jsonObject setObject:possibleReplacement forKey:key];
    object = possibleReplacement;
  }
  return object;
}

- (void)lsObjectifyAll {
  NSArray *keys = [_jsonObject allKeys];
  for (NSString *key in keys) {
    [self lsObjectifyAtKey:key];
  }
}

#pragma mark -
#pragma mark NSDictionary and NSMutableDictionary overrides

- (NSUInteger)count {
  return _jsonObject.count;
}

- (id)objectForKey:(id)key {
  return [self lsObjectifyAtKey:key];
}

- (NSEnumerator *)keyEnumerator {
  [self lsObjectifyAll];
  return _jsonObject.keyEnumerator;
}

- (void)setObject:(id)object forKey:(id)key {
  return [_jsonObject setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key {
  return [_jsonObject removeObjectForKey:key];
}

#pragma mark -
#pragma mark Private Class Members

+ (id)ifObjectWrappingObject:(id)originalObject {
  // non-array and non-dictionary case, returns original object
  id result = originalObject;
  
  // array and dictionary wrap
  if ([originalObject isKindOfClass:[NSDictionary class]]) {
    result = [[[IFObject alloc] initWrappingDictionary:originalObject] autorelease];
  } else if ([originalObject isKindOfClass:[NSArray class]]) {
    result = [[[IFObjectArray alloc] initWrappingArray:originalObject] autorelease];
  }
  
  // return our object
  return result;
}

// helper method used by the catgory implementation to determine whether a selector should be handled
+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel {
  // the overhead in this impl is high relative to the cost of a normal property
  // accessor; if needed we will optimize by caching results of the following
  // processing, indexed by selector
  
  NSString *selectorName = NSStringFromSelector(sel);
  int	parameterCount = [[selectorName componentsSeparatedByString:@":"] count]-1;
  // we will process a selector as a getter if paramCount == 0
  if (parameterCount == 0) {
    return SelectorInferredImplTypeGet;
    // otherwise we consider a setter if...
  } else if (parameterCount == 1 &&                   // ... we have the correct arity
             [selectorName hasPrefix:@"set"] &&       // ... we have the proper prefix
             selectorName.length > 4) {               // ... there are characters other than "set" & ":"
    return SelectorInferredImplTypeSet;
  }
  
  return SelectorInferredImplTypeNone;
}

+ (BOOL)isProtocolImplementationInferable:(Protocol*)protocol checkLSObjectAdoption:(BOOL)checkAdoption {
  // first handle base protocol questions
  if (checkAdoption && !protocol_conformsToProtocol(protocol, @protocol(IFObject))) {
    return NO;
  }
  
  if ([protocol isEqual:@protocol(IFObject)]) {
    return YES; // by definition
  }
  
  unsigned int count = 0;
  struct objc_method_description *methods = nil;
  
  // then confirm that all methods are required
  methods = protocol_copyMethodDescriptionList(protocol,
                                               NO,        // optional
                                               YES,       // instance
                                               &count);
  if (methods) {
    free(methods);
    return NO;
  }
  
  @try {
    // fetch methods of the protocol and confirm that each can be implemented automatically
    methods = protocol_copyMethodDescriptionList(protocol,
                                                 YES,   // required
                                                 YES,   // instance
                                                 &count);
    for (int index = 0; index < count; index++) {
      if ([IFObject inferredImplTypeForSelector:methods[index].name] == SelectorInferredImplTypeNone) {
        // we have a bad actor, short circuit
        return NO;
      }
    }
  } @finally {
    if (methods) {
      free(methods);
    }
  }
  
  // fetch adopted protocols
  Protocol **adopted = nil;
  @try {
    adopted = protocol_copyProtocolList(protocol, &count);
    for (int index = 0; index < count; index++) {
      // here we go again...
      if (![IFObject isProtocolImplementationInferable:adopted[index]
                                 checkLSObjectAdoption:NO]) {
        return NO;
      }
    }
  } @finally {
    if (adopted) {
      free(adopted);
    }
  }
  
  // protocol ran the gauntlet
  return YES;
}

#pragma mark -

@end

#pragma mark internal classes

@implementation IFObjectArray {
  NSMutableArray *_jsonArray;
}

- (id)initWrappingArray:(NSArray *)jsonArray {
  self = [super init];
  if (self) {
    if ([jsonArray isKindOfClass:[IFObjectArray class]]) {
      // in this case, we prefer to return the original object,
      // rather than allocate a wrapper
      
      // we are about to return this, better make it the caller's
      [jsonArray retain];
      
      // we don't need self after all
      [self release];
      
      // no wrapper needed, returning the object that was provided
      return (IFObjectArray*)jsonArray;
    } else {
      _jsonArray = [[NSMutableArray arrayWithArray:jsonArray] retain];
    }
  }
  return self;
}

- (void)dealloc {
  [_jsonArray release];
  [super dealloc];
}

- (NSUInteger)count {
  return _jsonArray.count;
}

- (id)lsObjectifyAtIndex:(NSUInteger)index {
  id object = [_jsonArray objectAtIndex:index];
  // make certain it is FBObjectGraph-ified
  id possibleReplacement = [IFObject ifObjectWrappingObject:object];
  if (object != possibleReplacement) {
    // and if not-yet, replace the original with the wrapped object
    [_jsonArray replaceObjectAtIndex:index withObject:possibleReplacement];
    object = possibleReplacement;
  }
  return object;
}

- (void)lsObjectifyAll {
  int count = [_jsonArray count];
  for (int i = 0; i < count; ++i) {
    [self lsObjectifyAtIndex:i];
  }
}

- (id)objectAtIndex:(NSUInteger)index {
  return [self lsObjectifyAtIndex:index];
}

- (NSEnumerator *)objectEnumerator {
  [self lsObjectifyAll];
  return _jsonArray.objectEnumerator;
}

- (NSEnumerator *)reverseObjectEnumerator {
  [self lsObjectifyAll];
  return _jsonArray.reverseObjectEnumerator;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
  [_jsonArray insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
  [_jsonArray removeObjectAtIndex:index];
}

- (void)addObject:(id)object {
  [_jsonArray addObject:object];
}

- (void)removeLastObject {
  [_jsonArray removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
  [_jsonArray replaceObjectAtIndex:index withObject:object];
}

@end

#pragma mark -