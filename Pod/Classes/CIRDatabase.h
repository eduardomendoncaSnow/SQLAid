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
@property(copy, nonatomic, nullable) void (^willExecuteBlock)(NSString *_Nonnull);

- (nonnull instancetype)initWithPath:(nonnull NSString *)databasePath;

- (nonnull instancetype)initWithHandler:(nonnull sqlite3 *)handler;

- (BOOL)open:(NSError *_Nullable *_Nullable)error;

- (BOOL)openWithFlags:(int)flags error:(NSError *_Nullable *_Nullable)error;

- (BOOL)isClosed;

- (BOOL)isOpen;

- (nullable CIRStatement *)prepareStatement:(nonnull NSString *)sql error:(NSError *_Nullable *_Nullable)error;

- (BOOL)executeStatement:(nonnull NSString *)sql error:(NSError *_Nullable *_Nullable)error;

- (BOOL)executeUpdate:(nonnull NSString *)sql error:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters error:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)parameters error:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (BOOL)executeUpdate:(nonnull NSString *)sql withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters error:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (nullable CIRResultSet *)executeQuery:(nonnull NSString *)query error:(NSError *_Nullable *_Nullable)error;

- (nullable CIRResultSet *)executeQuery:(nonnull NSString *)query withNamedParameters:(nullable NSDictionary<NSString *, id> *)parameters error:(NSError *_Nullable *_Nullable)error;

- (nullable CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)parameters error:(NSError *_Nullable *_Nullable)error;

- (nullable CIRResultSet *)executeQuery:(nonnull NSString *)query withParameters:(nullable NSArray<id> *)listParameters orNamedParameters:(nullable NSDictionary<NSString *, id> *)namedParameters error:(NSError *_Nullable *_Nullable)error;

- (BOOL)executeQuery:(nonnull NSString *)query error:(NSError *_Nullable *_Nullable)error each:(nonnull void (^)(CIRResultSet *__nonnull))handler;

- (sqlite_int64)lastInsertedId;

- (nullable NSString *)lastErrorMessage;

- (nullable sqlite3 *)handler;

- (BOOL)close:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

@end
