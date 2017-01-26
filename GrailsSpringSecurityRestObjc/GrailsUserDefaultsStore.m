#import "GrailsUserDefaultsStore.h"
#import "GrailsJwt.h"

static NSString *kJwtKeyUsername = @"jwtUsername";
static NSString *kJwtKeyRoles = @"jwtRoles";
static NSString *kJwtKeyAccessToken = @"jwtAccessToken";
static NSString *kJwtKeyRefreshToken = @"jwtRefreshToken";
static NSString *kJwtKeyTokenType = @"jwtTokenType";
static NSString *kJwtKeyExpiresIn = @"jwtExpiresIn";

@implementation GrailsUserDefaultsStore

#pragma mark - Lifecyle
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

+ (GrailsUserDefaultsStore *)sharedStore {
    static GrailsUserDefaultsStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

+ (void)initialize {
    NSDictionary *defaults = @{};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

#pragma mark - GrailsJwtStoragePr

- (GrailsJwt *)jwt {
    
    GrailsJwt *jwt = [[GrailsJwt alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    jwt.username = [userDefaults objectForKey:kJwtKeyUsername];
    jwt.roles = [userDefaults objectForKey:kJwtKeyRoles];
    jwt.accessToken = [userDefaults objectForKey:kJwtKeyAccessToken];
    jwt.refreshToken = [userDefaults objectForKey:kJwtKeyRefreshToken];
    jwt.tokenType = [userDefaults objectForKey:kJwtKeyTokenType];
    jwt.expiresIn = [[userDefaults objectForKey:kJwtKeyExpiresIn] integerValue];
    
    return jwt;    
}

- (void)saveJwt:(GrailsJwt *)jwt {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:jwt.username forKey:kJwtKeyUsername];
    [userDefaults setObject:jwt.roles forKey:kJwtKeyRoles];
    [userDefaults setObject:jwt.accessToken forKey:kJwtKeyAccessToken];
    [userDefaults setObject:jwt.refreshToken forKey:kJwtKeyRefreshToken];
    [userDefaults setObject:jwt.tokenType forKey:kJwtKeyTokenType];
    [userDefaults setObject:[NSNumber numberWithInteger:jwt.expiresIn] forKey:kJwtKeyExpiresIn];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteJwt {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kJwtKeyUsername];
    [userDefaults removeObjectForKey:kJwtKeyRoles];
    [userDefaults removeObjectForKey:kJwtKeyAccessToken];
    [userDefaults removeObjectForKey:kJwtKeyRefreshToken];
    [userDefaults removeObjectForKey:kJwtKeyTokenType];
    [userDefaults removeObjectForKey:kJwtKeyExpiresIn];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
