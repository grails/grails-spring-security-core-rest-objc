#import <Foundation/Foundation.h>
#import "GrailsJwtStoragePr.h"

@interface GrailsUserDefaultsStore : NSObject <GrailsJwtStoragePr>

- (GrailsJwt *)jwt;

- (void)saveJwt:(GrailsJwt *)jwt;

- (void)deleteJwt;

+ (GrailsUserDefaultsStore *)sharedStore;

@end
