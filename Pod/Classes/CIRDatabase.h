//
//  CIRDatabase.h
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@class CIRResultSet;
@class CIRStatement;

@interface CIRDatabase : NSObject

@property(readonly, nonatomic) NSString *path;
@property(strong, nonatomic) NSString *temporaryDirectory;
@property(copy, nonatomic) void (^willExecuteCIRBlock)(NSString *);

- (instancetype)initWithPath:(NSString *)databasePath;

- (void)open;

- (void)openWithFlags:(int)flags;

- (BOOL)isClosed;

- (BOOL)isOpen;

- (CIRStatement *)prepareStatement:(NSString *)sql;

- (void)executeStatement:(NSString *)sql;

- (BOOL)executeUpdate:(NSString *)sql;

- (BOOL)executeUpdate:(NSString *)sql withNamedParameters:(NSDictionary<NSString *, id> *)parameters;

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)parameters;

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters;

- (CIRResultSet *)executeQuery:(NSString *)query;

- (CIRResultSet *)executeQuery:(NSString *)query withNamedParameters:(NSDictionary<NSString *, id> *)parameters;

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)parameters;

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters;

- (void)executeQuery:(NSString *)query each:(void (^)(CIRResultSet *))handler;

- (sqlite_int64)lastInsertedId;

- (NSString *)lastErrorMessage;

- (sqlite3 *)handler;

- (BOOL)close;

@end
