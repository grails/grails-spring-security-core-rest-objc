#import <Foundation/Foundation.h>

@interface GrailsRefreshRequest : NSObject

@property (nonatomic, copy)NSString *path;
@property (nonatomic, copy)NSString *serverUrl;
@property (nonatomic, copy)NSString *refreshToken;
@property (nonatomic, copy)NSString *refreshTokenPropertyName;
@property (nonatomic, copy)NSString *grantTypePropertyName;
@property (nonatomic, copy)NSString *grantType;

- (id)initWithGrailsServerUrl:(NSString *)serverUrl refreshToken:(NSString *)refreshToken;

- (id)init;

- (NSDictionary *)params;

@end
