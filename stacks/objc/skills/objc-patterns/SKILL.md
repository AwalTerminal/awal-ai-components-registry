# Objective-C Patterns

## ARC Memory Management

```objc
// Strong reference (default) — owns the object
@property (nonatomic, strong) NSArray<User *> *users;

// Weak reference — does not own, nils out when deallocated
@property (nonatomic, weak) id<UserDelegate> delegate;

// Copy for value semantics (important for NSString, NSArray from mutable sources)
@property (nonatomic, copy) NSString *name;

// Break retain cycles in blocks
- (void)fetchDataWithCompletion:(void (^)(NSData *))completion {
    __weak typeof(self) weakSelf = self;
    [self.session dataTaskWithURL:self.url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf processData:data];
        completion(data);
    }];
}

// Autoreleasepool for loops creating many temporary objects
- (void)processLargeDataset:(NSArray *)items {
    for (NSUInteger i = 0; i < items.count; i++) {
        @autoreleasepool {
            NSData *processed = [self heavyTransform:items[i]];
            [self saveToFile:processed index:i];
        }
    }
}
```

## Blocks

```objc
// Block as a property (use copy)
@property (nonatomic, copy) void (^onComplete)(BOOL success, NSError *error);

// Block typedef for readability
typedef void (^CompletionHandler)(NSData * _Nullable data, NSError * _Nullable error);
typedef BOOL (^FilterBlock)(id item);

// Block as method parameter
- (void)fetchUser:(NSString *)userId completion:(CompletionHandler)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [self performRequest:userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data, nil);
        });
    });
}

// Enumeration with blocks
[self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isEqual:target]) {
        *stop = YES;  // early exit
    }
}];
```

## Protocols and Delegates

```objc
// Protocol definition
@protocol DataSourceDelegate <NSObject>
@required
- (NSInteger)numberOfItems;
- (id)itemAtIndex:(NSInteger)index;
@optional
- (void)didSelectItemAtIndex:(NSInteger)index;
@end

// Protocol adoption in implementation
@interface TableManager : NSObject <DataSourceDelegate>
@end

@implementation TableManager
- (NSInteger)numberOfItems { return self.data.count; }
- (id)itemAtIndex:(NSInteger)index { return self.data[index]; }
@end

// Check optional methods before calling
if ([self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
    [self.delegate didSelectItemAtIndex:selectedIndex];
}
```

## Categories and Extensions

```objc
// Category — add methods to existing classes (separate .h/.m)
// NSString+Validation.h
@interface NSString (Validation)
- (BOOL)isValidEmail;
- (NSString *)trimmedString;
@end

// NSString+Validation.m
@implementation NSString (Validation)
- (BOOL)isValidEmail {
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [pred evaluateWithObject:self];
}
- (NSString *)trimmedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end

// Class extension — private interface in .m file
@interface UserManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, User *> *cache;
- (void)invalidateCache;
@end
```

## KVO and KVC

```objc
// Key-Value Observing
- (void)startObserving {
    [self.user addObserver:self
               forKeyPath:@"name"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        NSString *newName = change[NSKeyValueChangeNewKey];
        [self updateUI:newName];
    }
}

- (void)dealloc {
    [self.user removeObserver:self forKeyPath:@"name"];
}

// Key-Value Coding
NSString *name = [user valueForKeyPath:@"address.city"];
[user setValue:@"New York" forKeyPath:@"address.city"];
```

## Toll-Free Bridging and Swift Interop

```objc
// Toll-free bridging between Foundation and Core Foundation
CFStringRef cfStr = (__bridge CFStringRef)nsString;
NSString *nsStr = (__bridge_transfer NSString *)CFStringCreateCopy(NULL, cfStr);

// NS_ENUM for Swift-friendly enumerations
typedef NS_ENUM(NSInteger, ConnectionState) {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected,
};

// Nullability annotations for Swift interop
NS_ASSUME_NONNULL_BEGIN
@interface APIClient : NSObject
- (void)fetchData:(NSString *)endpoint
       completion:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completion;
+ (instancetype)sharedClient;
@end
NS_ASSUME_NONNULL_END

// NS_SWIFT_NAME for better Swift API naming
- (void)performActionWithTarget:(id)target options:(NSDictionary *)opts
    NS_SWIFT_NAME(performAction(target:options:));
```

## Error Handling

```objc
// NSError out-parameter pattern
- (BOOL)saveData:(NSData *)data toPath:(NSString *)path error:(NSError **)error {
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.myapp"
                                         code:100
                                     userInfo:@{NSLocalizedDescriptionKey: @"Data is nil"}];
        }
        return NO;
    }
    return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

// Calling code
NSError *error = nil;
if (![manager saveData:data toPath:path error:&error]) {
    NSLog(@"Save failed: %@", error.localizedDescription);
}
```

## Testing with XCTest

```objc
@interface UserManagerTests : XCTestCase
@property (nonatomic, strong) UserManager *sut;
@end

@implementation UserManagerTests
- (void)setUp {
    [super setUp];
    self.sut = [[UserManager alloc] init];
}

- (void)testFetchUserReturnsData {
    XCTestExpectation *exp = [self expectationWithDescription:@"fetch"];
    [self.sut fetchUser:@"123" completion:^(User *user, NSError *error) {
        XCTAssertNotNil(user);
        XCTAssertNil(error);
        XCTAssertEqualObjects(user.userId, @"123");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testEmailValidation {
    XCTAssertTrue([@"user@example.com" isValidEmail]);
    XCTAssertFalse([@"invalid" isValidEmail]);
}
@end
```
