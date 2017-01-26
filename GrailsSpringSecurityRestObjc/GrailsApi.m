#import "GrailsApi.h"
#import "GrailsAuthenticationRequest.h"
#import "NSString+URLEncode.h"
#import "GrailsRefreshRequest.h"
#import "GrailsJwtBuilder.h"
#import "GrailsJwt.h"
#import "GrailsUserDefaultsStore.h" 
#import "GrailsJwtStoragePr.h"

static NSInteger FAST_TIME_INTERVAL = 5.0;

@interface GrailsApi () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong)GrailsJwtBuilder *jwtBuilder;

@property (nonatomic, strong)id<GrailsJwtStoragePr> jwtStorage;

@end

@implementation GrailsApi

#pragma mark - LifeCycle

- (id)init {
    if(self = [super init]) {
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - Private

- (NSURLRequest *)loginRequest:(GrailsAuthenticationRequest *)authenticationRequest {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [authenticationRequest serverUrl], [authenticationRequest path]];
    if ( ![authenticationRequest useJsonCredentials]) {
        [GrailsApi appendUrlEncodedParameters:[authenticationRequest params] toString:urlString];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval:FAST_TIME_INTERVAL];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ( [authenticationRequest useJsonCredentials] ) {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *params = [authenticationRequest params];
        NSData *jsonData = [GrailsApi buildJSONBodyDataWithParams:params];
        if(jsonData) {
            [urlRequest setHTTPBody:jsonData];
        }
    }
    
    return urlRequest;
}

- (NSURLRequest *)refreshRequest:(GrailsRefreshRequest *)refreshRequest {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [refreshRequest serverUrl], [refreshRequest path]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *params = [refreshRequest params];
    
    NSString *post =[NSString stringWithFormat:@"grant_type=%@&refresh_token=%@",params[@"grant_type"], params[@"refresh_token"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%@",@([postData length])];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:FAST_TIME_INTERVAL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    return request;
}

+ (NSData *)buildJSONBodyDataWithParams:(id)params {
    NSData *jsonData = nil;
    
    if([params isKindOfClass:[NSDictionary class]]) {
        NSError *jsonSerializationError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonSerializationError];
        
    } else if([params isKindOfClass:[NSString class]]) {
        jsonData = [params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    }
    return jsonData;
}

+ (NSString *)appendUrlEncodedParameters:(id)params toString:(NSString *)urlString {
    __block NSString *urlStr = urlString;
    
    if([params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)params;
        urlStr = [urlString stringByAppendingString:@"?"];
        
        for(id key in [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((NSString *)obj1) caseInsensitiveCompare:((NSString *)obj2)];
        }]) {
            NSString *obj = dict[key];
            if([dict[key] isKindOfClass:[NSString class]]) {
                obj = [((NSString *)dict[key]) urlencode];
            }
            urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,obj]];
        }
    }
    
    if([urlStr hasSuffix:@"&"]) {
        urlStr = [urlStr substringToIndex:([urlStr length] -1)];
    }
    
    return urlStr;
}

- (NSString *)refreshToken {
    GrailsJwt *jwt = [self.jwtStorage jwt];
    return [jwt refreshToken];
}

- ( NSError *)errorWithCode:(NSInteger)errorCode {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    return [NSError errorWithDomain:kGrailsErrorDomain
                               code:errorCode
                           userInfo:userInfo];
}

#pragma mark - Public

- (void)logout {
    [self.jwtStorage deleteJwt];
}

- (NSString *)accessToken {
    GrailsJwt *jwt = [self.jwtStorage jwt];
    return [jwt accessToken];
}

- (NSString *)loggedUsername {
    GrailsJwt *jwt = [self.jwtStorage jwt];
    return [jwt username];
}

- (BOOL)hasRole:(NSString *)roleName {
    GrailsJwt *jwt = [self.jwtStorage jwt];
    NSArray *roles = [jwt roles];
    return [roles containsObject:roleName];
}

- (void)loginGrailsServerUrl:(NSString *)grailsServerUrl username:(NSString *)username password:(NSString *)password withCompletionHandler:(void (^)(NSError *error))completionHandler {
    
    GrailsAuthenticationRequest *authenticationRequest = [[GrailsAuthenticationRequest alloc] initWithGrailsServerUrl:grailsServerUrl
                                                                                                             username:username
                                                                                                             password:password];
    [self login:authenticationRequest withCompletionHandler:completionHandler];
}

- (void)login:(GrailsAuthenticationRequest *)authenticationRequest withCompletionHandler:(void (^)(NSError *error))completionHandler {
    
    NSURLRequest *urlRequest = [self loginRequest:authenticationRequest];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            if ( completionHandler ) {
                completionHandler(error);
            }
            return;
        }
        
        NSInteger statusCode = [((NSHTTPURLResponse*)response) statusCode];
        if(statusCode == 200) {
            NSString *objectNotation = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *builderError;
            GrailsJwt *jwt = [self.jwtBuilder jwtFromJSON:objectNotation error:&builderError];
            if(builderError) {
                if ( completionHandler ) {
                    completionHandler(builderError);
                }
                return;
            }
            
            [self.jwtStorage saveJwt:jwt];
            completionHandler(nil);
            return;
        } else if ( statusCode == 401 ) {
            NSError *e = [self errorWithCode:kGrailsLoginUnauthorizedError];
            if ( completionHandler ) {
                completionHandler(e);
            }
            return;
        }
        
        NSError *e = [self errorWithCode:kGrailsLoginError];
        if ( completionHandler ) {
            completionHandler(e);
        }
        return;
    }];
    [dataTask resume];
}

- (void)refreshTokenGrailsServerUrl:(NSString *)grailsServerUrl refreshToken:(NSString *)refreshToken withCompletionHandler:(void (^)(NSError *error))completionHandler {
    
    GrailsRefreshRequest *refreshRequest = [[GrailsRefreshRequest alloc] initWithGrailsServerUrl:grailsServerUrl
                                                                                    refreshToken:refreshToken];
    [self refreshToken:refreshRequest withCompletionHandler:completionHandler];
}

- (void)refreshToken:(GrailsRefreshRequest *)refreshRequest withCompletionHandler:(void (^)(NSError *error))completionHandler {
    NSURLRequest *urlRequest = [self refreshRequest:refreshRequest];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if( error ) {
            if ( completionHandler ) {
                completionHandler(error);
            }
            return;
        }
        
        NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
        
        if ( statusCode == 200 ) {
            NSString *objectNotation = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *builderError;
            GrailsJwt *jwt = [self.jwtBuilder jwtFromJSON:objectNotation error:&builderError];
            if(builderError) {
                if ( completionHandler ) {
                    completionHandler(builderError);
                }
                return;
            }
            [self.jwtStorage saveJwt:jwt];
            
        } else if ( statusCode == 403 ) {
            
            NSError *e = [self errorWithCode:kGrailsRefreshForbiddenError];
            if ( completionHandler ) {
                completionHandler(e);
            }
            return;
            
        } else if ( statusCode == 400 ) {
            NSError *e = [self errorWithCode:kGrailsRefreshBadRequestError];
            if ( completionHandler ) {
                completionHandler(e);
            }
            return;
        }
        
        NSError *e = [self errorWithCode:kGrailsRefreshError];
        if ( completionHandler ) {
            completionHandler(e);
        }
        return;
        
    }];
    [dataTask resume];
}

- (void)refreshAccessTokenGrailsServerUrl:(NSString *)grailsServerUrl withCompletionHandler:(void (^)(NSError *error))completionHandler {
    
    NSString *refreshToken = [self refreshToken];
    
    [self refreshTokenGrailsServerUrl:grailsServerUrl refreshToken:refreshToken withCompletionHandler:completionHandler];
}

#pragma mark - Lazy

- (GrailsJwtBuilder *)jwtBuilder {
    if ( _jwtBuilder == nil ) {
        _jwtBuilder = [[GrailsJwtBuilder alloc] init];
    }
    return _jwtBuilder;
}

- (id<GrailsJwtStoragePr>)jwtStorage {
    if ( _jwtStorage == nil ) {
        _jwtStorage = [GrailsUserDefaultsStore sharedStore];
    }
    return _jwtStorage;
}

@end

NSString *kGrailsErrorDomain = @"GrailsErrorDomain";
