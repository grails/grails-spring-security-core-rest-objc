@class GrailsJwt;

@protocol GrailsJwtStoragePr <NSObject>

- (GrailsJwt *)jwt;

- (void)saveJwt:(GrailsJwt *)jwt;

- (void)deleteJwt;

@end
