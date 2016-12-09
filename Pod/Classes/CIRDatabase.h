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

- (void)open;

- (void)openWithFlags:(int)flags;

- (BOOL)isClosed;

- (BOOL)isOpen;

- (nonnull CIRStatement *)prepareStatement:(nonnull NSString *)sql;

- (void)executeStatement:(nonnull NSString *)sql;

- (BOOL)executeUpdate:(nonnull NSString *)sql;

- (BOOL)executeUpdate:(nonnull NSString *)sql withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters;

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)parameters;

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)parameters;

- (nonnull CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters;

- (void)executeQuery:(nonnull NSString *)query each:(nonnull void (^)(CIRResultSet *__nonnull))handler;

- (sqlite_int64)lastInsertedId;

- (nullable NSString *)lastErrorMessage;

- (nullable sqlite3 *)handler;

- (BOOL)close;

@end
