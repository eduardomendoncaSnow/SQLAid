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

- (instancetype)initWithDatabase:(CIRDatabase *)database andStatement:(CIRStatement *)statement;

- (BOOL)next;

- (BOOL)close;

- (BOOL)isClosed;

- (BOOL)isColumnAtIndexNull:(int)columnIndex;

- (int)columnCount;

- (int)columnIndexWithName:(NSString *)columnName;

- (int)columnTypeAtIndex:(int)columnIndex;

- (int)intAtIndex:(int)columnIndex;

- (int)intWithColumnName:(NSString *)columnName;

- (long)longAtIndex:(int)columnIndex;

- (long)longWithColumnName:(NSString *)columnName;

- (sqlite3_int64)longLongAtIndex:(int)columnIndex;

- (sqlite3_int64)longLongWithColumnName:(NSString *)columnName;

- (double)doubleAtIndex:(int)columnIndex;

- (double)doubleWithColumnName:(NSString *)columnName;

- (BOOL)boolAtIndex:(int)columnIndex;

- (BOOL)boolWithColumnName:(NSString *)columnName;

- (NSString *)textAtIndex:(int)columnIndex;

- (NSString *)textWithColumnName:(NSString *)columnName;

- (NSDate *)unixDateAtIndex:(int)columnIndex;

- (NSDate *)unixDateWithColumnName:(NSString *)columnName;

- (NSDecimalNumber *)decimalNumberAtIndex:(int)columnIndex;

- (NSDecimalNumber *)decimalNumberWithColumnName:(NSString *)columnName;

- (id)objectAtIndex:(NSUInteger)columnIndex;

- (id)objectWithColumnName:(NSString *)columnName;

- (id)objectAtIndexedSubscript:(NSUInteger)index;

- (NSString *)sql;

@end
