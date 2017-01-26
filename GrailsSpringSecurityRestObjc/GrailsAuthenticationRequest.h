#import <Foundation/Foundation.h>

@interface GrailsAuthenticationRequest : NSObject

@property (nonatomic, copy)NSString *path;
@property (nonatomic, copy)NSString *usernamePropertyName;
@property (nonatomic, copy)NSString *passwordPropertyName;
@property (nonatomic, copy)NSString *serverUrl;
@property (nonatomic, copy)NSString *username;
@property (nonatomic, copy)NSString *password;
@property (nonatomic)BOOL useJsonCredentials;

- (id)initWithGrailsServerUrl:(NSString *)serverUrl
                     username:(NSString *)username
                     password:(NSString *)password;

- (id)init;

- (NSDictionary *)params;

@end
