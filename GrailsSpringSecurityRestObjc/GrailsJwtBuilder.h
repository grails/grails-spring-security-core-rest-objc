#import <Foundation/Foundation.h>

@class GrailsJwt;

extern NSString *kJwtBuilderErrorDomain;

enum {
    kJwtBuilderInvalidJSONError,
    kJwtBuilderMissingDataError,
};

@interface GrailsJwtBuilder : NSObject

- (GrailsJwt *)jwtFromJSON:(NSString *)objectNotation
                     error:(NSError **)error;

@end
