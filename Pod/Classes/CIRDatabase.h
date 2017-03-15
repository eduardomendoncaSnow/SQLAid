//
//  CIRDatabase.h
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3/sqlite3.h>

@class CIRResultSet;
@class CIRStatement;

@interface CIRDatabase : NSObject

@property(readonly, nonatomic, nonnull) NSString *path;
@property(strong, nonatomic, nonnull) NSString *temporaryDirectory;
@property(copy, nonatomic, nullable) void (^willExecuteBlock)(NSString *__nonnull);

- (nonnull instancetype)initWithPath:(nonnull NSString *)databasePath;

- (void)open:(NSError __nullable* __nullable*)error;

- (void)openWithFlags:(int)flags error:(NSError __nullable* __nullable*)error;

- (BOOL)isClosed;

- (BOOL)isOpen;

- (nonnull CIRStatement *)prepareStatement:(nonnull NSString *)sql error:(NSError __nullable* __nullable*)error;

- (void)executeStatement:(nonnull NSString *)sql error:(NSError __nullable* __nullable*)error;

- (BOOL)executeUpdate:(nonnull NSString *)sql error:(NSError __nullable* __nullable*)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters error:(NSError __nullable* __nullable*)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)parameters error:(NSError __nullable* __nullable*)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters error:(NSError __nullable* __nullable*)error __attribute__((warn_unused_result));

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query error:(NSError __nullable* __nullable*)error;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters error:(NSError __nullable* __nullable*)error;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)parameters error:(NSError __nullable* __nullable*)error;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters error:(NSError __nullable* __nullable*)error;

- (void)executeQuery:(nonnull NSString *)query error:(NSError __nullable* __nullable*)error each:(nonnull void (^)(CIRResultSet *__nonnull))handler;

- (sqlite_int64)lastInsertedId;

- (nullable NSString *)lastErrorMessage;

- (nullable sqlite3 *)handler;

- (BOOL)close:(NSError __nullable* __nullable*)error __attribute__((warn_unused_result));

@end
