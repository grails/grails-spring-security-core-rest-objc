#import "GrailsAuthenticationRequest.h"

@implementation GrailsAuthenticationRequest

#pragma mark - Lifecyle
- (id)init {    
    if (self = [super init]) {
        [self populateWithDefaultValues];
    }
    return self;
}

- (id)initWithGrailsServerUrl:(NSString *)serverUrl
                     username:(NSString *)username password:(NSString *)password {
    
    if (self = [super init]) {
        [self populateWithDefaultValues];
        self.serverUrl = serverUrl;
        self.username = username;
        self.password = password;
    }
    return self;
}

#pragma mark - Private
- (void)populateWithDefaultValues {
    self.path = @"/api/login";
    self.usernamePropertyName = @"username";
    self.passwordPropertyName = @"password";
    self.useJsonCredentials = YES;
    
}

#pragma mark - Public

- (NSDictionary *)params {
    return @{self.usernamePropertyName: self.username, self.passwordPropertyName: self.password};
}

@end
