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

@property(readonly, nonatomic) NSUInteger columnCount;

- (nonnull instancetype)initWithStmt:(nonnull sqlite3_stmt *)stmt database:(nonnull CIRDatabase *)database;

- (int)bindInt:(int)value atIndex:(int)index;

- (int)bindLong:(long)value atIndex:(int)index;

- (int)bindLongLong:(long long)value atIndex:(int)index;

- (int)bindDouble:(double)value atIndex:(int)index;

- (int)bindText:(nonnull NSString *)value atIndex:(int)index;

- (int)bindNullAtIndex:(int)index;

- (void)bindObjects:(nonnull NSArray<id> *)objects;

- (int)bindObject:(nullable id)object atIndex:(int)index;

- (int)intAtIndex:(int)columnIndex;

- (long)longAtIndex:(int)columnIndex;

- (sqlite3_int64)longLongAtIndex:(int)columnIndex;

- (double)doubleAtIndex:(int)columnIndex;

- (nullable NSString *)textAtIndex:(int)columnIndex;

- (nullable id)objectAtIndex:(int)columnIndex;

- (int)columnTypeAtIndex:(int)columnIndex;

- (BOOL)isColumnAtIndexNull:(int)columnIndex;

- (nullable NSString *)columnNameAtIndex:(int)columnIndex;

- (int)columnIndexWithName:(nonnull NSString *)columnName;

- (int)step;

- (int)clearBindings;

- (int)reset;

- (int)bindParameterCount;

- (int)bindIndexWithName:(nonnull NSString *)paramenterName;

- (BOOL)isClosed;

- (int)close:(NSError *_Nullable *_Nullable)error __attribute__((warn_unused_result));

- (nullable sqlite3_stmt *)handler;

- (nullable NSString *)sql;

@end
