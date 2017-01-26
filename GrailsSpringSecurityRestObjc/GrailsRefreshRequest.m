#import "GrailsRefreshRequest.h"

@implementation GrailsRefreshRequest

- (id)initWithGrailsServerUrl:(NSString *)serverUrl
                 refreshToken:(NSString *)refreshToken {
    
    if (self = [super init]) {
        [self populateWithDefaultValues];
        self.refreshToken = refreshToken;
        self.serverUrl = serverUrl;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self populateWithDefaultValues];
    }
    return self;
}

#pragma mark - Private
- (void)populateWithDefaultValues {
    self.path = @"/oauth/access_token";
    self.refreshTokenPropertyName = @"refresh_token";
    self.grantTypePropertyName = @"grant_type";
    self.grantType = @"refresh_token";
}

- (NSDictionary *)params {
    return @{self.refreshTokenPropertyName: self.refreshToken,
             self.grantTypePropertyName: self.grantType};
}
@end
