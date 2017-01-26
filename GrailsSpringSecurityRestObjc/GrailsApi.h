#import <Foundation/Foundation.h>

@protocol GrailsApiLoginDelegate;
@class GrailsAuthenticationRequest, GrailsRefreshRequest;

extern NSString *kGrailsErrorDomain;

typedef NS_ENUM(NSInteger, GrailsError) {
    kGrailsRefreshBadRequestError,
    kGrailsRefreshForbiddenError,
    kGrailsRefreshError,
    kGrailsLoginUnauthorizedError,
    kGrailsLoginError    
};

@interface GrailsApi : NSObject

- (void)loginGrailsServerUrl:(NSString *)grailsServerUrl
                    username:(NSString *)username
                    password:(NSString *)password
       withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (void)refreshAccessTokenGrailsServerUrl:(NSString *)grailsServerUrl
                    withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (void)login:(GrailsAuthenticationRequest *)authenticationRequest
withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (void)refreshTokenGrailsServerUrl:(NSString *)grailsServerUrl
                       refreshToken:(NSString *)refreshToken
              withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (void)refreshToken:(GrailsRefreshRequest *)refreshRequest
withCompletionHandler:(void (^)(NSError *error))completionHandler;

- (BOOL)hasRole:(NSString *)roleName;

- (NSString *)loggedUsername;

- (void)logout;

- (NSString *)accessToken;

+ (NSData *)buildJSONBodyDataWithParams:(id)params;

@end
