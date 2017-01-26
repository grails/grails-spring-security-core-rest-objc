#import <Foundation/Foundation.h>

@interface GrailsJwt : NSObject

@property (nonatomic, copy)NSArray *roles;

@property (nonatomic, copy)NSString *username;

@property (nonatomic, copy)NSString *accessToken;

@property (nonatomic, copy)NSString *refreshToken;

@property (nonatomic, copy)NSString *tokenType;

@property (nonatomic)NSInteger expiresIn;

@end
