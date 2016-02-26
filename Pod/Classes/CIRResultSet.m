//
//  CIRResultSet.m
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import "CIRResultSet.h"

#import "CIRDatabase.h"
#import "CIRStatement.h"

@interface CIRResultSet ()

@property (strong, nonatomic) CIRDatabase* database;
@property (strong, nonatomic) CIRStatement* statement;

@end

@implementation CIRResultSet

- (instancetype)initWithDatabase:(CIRDatabase*)database andStatement:(CIRStatement*)statement
{
	if (self = [super init])
	{
		_database = database;
		_statement = statement;
		
		return self;
	}
	
	return nil;
}

- (BOOL)next
{
	BOOL value;
	int resultCode = [_statement step];
	
	if ((value = resultCode != SQLITE_ROW && [self close]))
	{
		if (resultCode != SQLITE_DONE) @throw [NSException exceptionWithName:@"Can't execute next" reason:[_database lastErrorMessage] userInfo:nil];
	}
	
	return !value;
}

- (BOOL)close
{
	if ([_statement isClosed]) return YES;
	
	return [_statement close] == SQLITE_OK;
}

- (BOOL)isClosed
{
	return [_statement isClosed];
}

- (int)columnCount
{
	return [_statement columnCount];
}

- (int)columnIndexWithName:(NSString*)columnName
{
	return [_statement columnIndexWithName:columnName];
}

- (int)columnTypeAtIndex:(int)columnIndex
{
	return [_statement columnTypeAtIndex:columnIndex];
}

- (BOOL)isColumnAtIndexNull:(int)columnIndex
{
	return [_statement isColumnAtIndexNull:columnIndex];
}

- (int)intAtIndex:(int)columnIndex
{
	return [_statement intAtIndex:columnIndex];
}

- (int)intWithColumnName:(NSString*)columnName
{
	return [self intAtIndex:[self columnIndexWithName:columnName]];
}

- (long)longAtIndex:(int)columnIndex
{
	return [_statement longAtIndex:columnIndex];
}

- (long)longWithColumnName:(NSString*)columnName
{
	return [self longAtIndex:[self columnIndexWithName:columnName]];
}

- (sqlite3_int64)longLongAtIndex:(int)columnIndex
{
	return [_statement longLongAtIndex:columnIndex];
}

- (sqlite3_int64)longLongWithColumnName:(NSString*)columnName
{
	return [self longLongAtIndex:[self columnIndexWithName:columnName]];
}

- (double)doubleAtIndex:(int)columnIndex
{
	return [_statement doubleAtIndex:columnIndex];
}

- (double)doubleWithColumnName:(NSString*)columnName
{
	return [self doubleAtIndex:[self columnIndexWithName:columnName]];
}

- (BOOL)boolAtIndex:(int)columnIndex
{
	return [_statement intAtIndex:columnIndex] == 1;
}

- (BOOL)boolWithColumnName:(NSString*)columnName
{
	return [self boolAtIndex:[self columnIndexWithName:columnName]];
}

- (NSString*)textAtIndex:(int)columnIndex
{
	return [_statement textAtIndex:columnIndex];
}

- (NSString*)textWithColumnName:(NSString*)columnName
{
	return [self textAtIndex:[self columnIndexWithName:columnName]];
}

- (NSDate*)unixDateAtIndex:(int)columnIndex
{
	return [NSDate dateWithTimeIntervalSince1970:[self longAtIndex:columnIndex]];
}

- (NSDate*)unixDateWithColumnName:(NSString*)columnName
{
	return [self unixDateAtIndex:[self columnIndexWithName:columnName]];
}

- (NSDecimalNumber*)decimalNumberAtIndex:(int)columnIndex
{
	return [[NSDecimalNumber alloc] initWithDecimal:@([self doubleAtIndex:columnIndex]).decimalValue];
}

- (NSDecimalNumber*)decimalNumberWithColumnName:(NSString*)columnName
{
	return [self decimalNumberAtIndex:[self columnIndexWithName:columnName]];
}

- (id)objectAtIndex:(NSUInteger)columnIndex
{
	return [_statement objectAtIndex:(int)columnIndex];
}

- (id)objectWithColumnName:(NSString*)columnName
{
	return [self objectAtIndex:[self columnIndexWithName:columnName]];
}

- (NSString*)sql
{
	return [_statement sql];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	return [self objectAtIndex:index];
}

@end
