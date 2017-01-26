#import "GrailsJwtBuilder.h"
#import "GrailsJwt.h"

static NSString *kJSONKeyUsername = @"username";
static NSString *kJSONKeyRoles = @"roles";
static NSString *kJSONKeyTokenType = @"token_type";
static NSString *kJSONKeyAccessToken = @"access_token";
static NSString *kJSONKeyRefreshToken = @"refresh_token";
static NSString *kJSONKeyExpiresIn = @"expires_in";

@implementation GrailsJwtBuilder

#pragma mark - Public

- (GrailsJwt *)jwtFromJSON:(NSString *)objectNotation
                     error:(NSError **)error {
    
    NSDictionary *parsedObject = [self parseJSON:objectNotation
                                           error:error
                            invalidJSONErrorCode:kJwtBuilderInvalidJSONError
                                     errorDomain:kJwtBuilderErrorDomain];
    
    return [self newElementWithDictionary:parsedObject
                                    error:error
                     invalidJSONErrorCode:kJwtBuilderInvalidJSONError
                     missingDataErrorCode:kJwtBuilderMissingDataError
                              errorDomain:kJwtBuilderErrorDomain];
    
}

#pragma mark - Private

- (NSDictionary *)parseJSON:(NSString *)objectNotation
                      error:(NSError **)error
       invalidJSONErrorCode:(NSInteger)invalidJSONErrorCode
                errorDomain:(NSString *)errorDomain  {
    
    NSParameterAssert(objectNotation != nil);
    id jsonObject;
    
    NSError *localError = nil;
    if(objectNotation != nil) {
        NSData *unicodeNotation = [objectNotation dataUsingEncoding:NSUTF8StringEncoding];
        jsonObject = [NSJSONSerialization JSONObjectWithData:unicodeNotation
                                                     options:0
                                                       error:&localError];
    }
    NSDictionary *parsedObject = (id)jsonObject;
    if (parsedObject == nil) {
        if (error != NULL) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
            if (localError != nil) {
                [userInfo setObject:localError forKey:NSUnderlyingErrorKey];
            }
            *error = [NSError errorWithDomain:errorDomain code:invalidJSONErrorCode userInfo:userInfo];
        }
        return nil;
    }
    return parsedObject;
}


- (id)newElementWithDictionary:(NSDictionary *)dict
                         error:(NSError **)error
          invalidJSONErrorCode:(NSInteger)invalidJSONErrorCode
          missingDataErrorCode:(NSInteger)missingDataErrorCode
                   errorDomain:(NSString *)errorDomain {
    
    GrailsJwt *jwt = [[GrailsJwt alloc] init];
    
    if([[dict objectForKey:kJSONKeyUsername] isKindOfClass:[NSString class]]) {
        jwt.username = (NSString *)[dict objectForKey:kJSONKeyUsername];
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    
    if([[dict objectForKey:kJSONKeyTokenType] isKindOfClass:[NSString class]]) {
        jwt.tokenType = (NSString *)[dict objectForKey:kJSONKeyTokenType];
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    
    if([[dict objectForKey:kJSONKeyAccessToken] isKindOfClass:[NSString class]]) {
        jwt.accessToken = (NSString *)[dict objectForKey:kJSONKeyAccessToken];
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    
    if([[dict objectForKey:kJSONKeyRefreshToken] isKindOfClass:[NSString class]]) {
        jwt.refreshToken = (NSString *)[dict objectForKey:kJSONKeyRefreshToken];
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    
    if([[dict objectForKey:kJSONKeyExpiresIn] isKindOfClass:[NSNumber class]]) {
        jwt.expiresIn = [(NSNumber *)[dict objectForKey:kJSONKeyExpiresIn] integerValue];
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    
    
    if([[dict objectForKey:kJSONKeyRoles] isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)[dict objectForKey:kJSONKeyRoles];
        
        NSMutableArray *roles = [[NSMutableArray alloc] init];
        for(id obj in arr) {
            if([obj isKindOfClass:[NSString class]]) {
                NSString *role = (NSString *)obj;
                [roles addObject:role];
            }
        }
        jwt.roles = roles;
        
    } else {
        if(error != NULL) {
            *error = [self invalidJsonError];
        }
        return nil;
    }
    return jwt;
}

- ( NSError *)invalidJsonError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    return [NSError errorWithDomain:kJwtBuilderErrorDomain
                               code:kJwtBuilderInvalidJSONError
                           userInfo:userInfo];
}


@end

NSString *kJwtBuilderErrorDomain = @"kJwtBuilderErrorDomain";
