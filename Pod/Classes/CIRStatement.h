//
//  CIRStatement.h
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3/sqlite3.h>

@class CIRDatabase;

@interface CIRStatement : NSObject

@property(readonly, nonatomic) int columnCount;

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt;

- (int)bindInt:(int)value atIndex:(int)index;

- (int)bindLong:(long)value atIndex:(int)index;

- (int)bindLongLong:(long long)value atIndex:(int)index;

- (int)bindDouble:(double)value atIndex:(int)index;

- (int)bindText:(NSString *)value atIndex:(int)index;

- (int)bindNullAtIndex:(int)index;

- (void)bindObjects:(NSArray<id> *)objects;

- (int)bindObject:(id)object atIndex:(int)index;

- (int)intAtIndex:(int)columnIndex;

- (long)longAtIndex:(int)columnIndex;

- (sqlite3_int64)longLongAtIndex:(int)columnIndex;

- (double)doubleAtIndex:(int)columnIndex;

- (NSString *)textAtIndex:(int)columnIndex;

- (id)objectAtIndex:(int)columnIndex;

- (int)columnTypeAtIndex:(int)columnIndex;

- (BOOL)isColumnAtIndexNull:(int)columnIndex;

- (NSString *)columnNameAtIndex:(int)columnIndex;

- (int)columnIndexWithName:(NSString *)columnName;

- (int)step;

- (int)clearBindings;

- (int)reset;

- (int)bindParameterCount;

- (int)bindIndexWithName:(NSString *)paramenterName;

- (BOOL)isClosed;

- (int)close;

- (sqlite3_stmt *)handler;

- (NSString *)sql;

@end
