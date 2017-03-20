//
//  CIRResultSet.h
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3/sqlite3.h>

@class CIRDatabase;
@class CIRStatement;

@interface CIRResultSet : NSObject

- (nonnull instancetype)initWithDatabase:(nonnull CIRDatabase *)database andStatement:(nonnull CIRStatement *)statement;

- (BOOL)next:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (BOOL)close:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (BOOL)isClosed;

- (BOOL)isColumnAtIndexNull:(int)columnIndex;

- (int)columnCount;

- (int)columnIndexWithName:(nonnull NSString *)columnName;

- (int)columnTypeAtIndex:(int)columnIndex;

- (int)intAtIndex:(int)columnIndex;

- (int)intWithColumnName:(nonnull NSString *)columnName;

- (long)longAtIndex:(int)columnIndex;

- (long)longWithColumnName:(nonnull NSString *)columnName;

- (sqlite3_int64)longLongAtIndex:(int)columnIndex;

- (sqlite3_int64)longLongWithColumnName:(nonnull NSString *)columnName;

- (double)doubleAtIndex:(int)columnIndex;

- (double)doubleWithColumnName:(nonnull NSString *)columnName;

- (BOOL)boolAtIndex:(int)columnIndex;

- (BOOL)boolWithColumnName:(nonnull NSString *)columnName;

- (nullable NSString *)textAtIndex:(int)columnIndex;

- (nullable NSString *)textWithColumnName:(nonnull NSString *)columnName;

- (nullable NSDate *)unixDateAtIndex:(int)columnIndex;

- (nullable NSDate *)unixDateWithColumnName:(nonnull NSString *)columnName;

- (nullable NSDecimalNumber *)decimalNumberAtIndex:(int)columnIndex;

- (nullable NSDecimalNumber *)decimalNumberWithColumnName:(nonnull NSString *)columnName;

- (nullable id)objectAtIndex:(NSUInteger)columnIndex;

- (nullable id)objectWithColumnName:(nonnull NSString *)columnName;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)index;

- (nullable NSString *)sql;

@end
