//
//  CIRStatement.m
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import "CIRStatement.h"
#import "CIRDatabase.h"

@interface CIRStatement ()

@property (assign, nonatomic) sqlite3_stmt *stmt;
@property (weak, nonatomic) CIRDatabase *database;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *columnNameIndexes;

@end

@implementation CIRStatement

- (instancetype)initWithStmt:(sqlite3_stmt *)stmt database:(CIRDatabase *)database
{
	if (self = [super init])
	{
		_stmt = stmt;
		_database = database;

		_columnCount = (NSUInteger) sqlite3_column_count(stmt);

		NSMutableDictionary *columnNameIndexes = [[NSMutableDictionary alloc] initWithCapacity:_columnCount];

		for (int i = 0; i < _columnCount; i++)
			columnNameIndexes[[NSString stringWithUTF8String:sqlite3_column_name(stmt, i)]] = @(i);

		_columnNameIndexes = [NSDictionary dictionaryWithDictionary:columnNameIndexes];

		return self;
	}

	return nil;
}

- (int)bindInt:(int)value atIndex:(int)index
{
	return sqlite3_bind_int(_stmt, index, value);
}

- (int)bindLong:(long)value atIndex:(int)index
{
	return sqlite3_bind_int64(_stmt, index, value);
}

- (int)bindLongLong:(long long)value atIndex:(int)index
{
	return sqlite3_bind_int64(_stmt, index, value);
}

- (int)bindDouble:(double)value atIndex:(int)index
{
	return sqlite3_bind_double(_stmt, index, value);
}

- (int)bindText:(NSString *)value atIndex:(int)index
{
	return sqlite3_bind_text(_stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
}

- (int)bindNullAtIndex:(int)index
{
	return sqlite3_bind_null(_stmt, index);
}

- (void)bindObjects:(NSArray *)objects
{
	const NSUInteger count = [objects count];

	for (int i = 0; i < count; i++)
	{
		[self bindObject:objects[i] atIndex:i + 1];
	}
}

- (int)bindObject:(id)object atIndex:(int)index
{
	int resultCode;

	if (object == nil || object == [NSNull null])
	{
		resultCode = [self bindNullAtIndex:index];
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		resultCode = [self bindText:object atIndex:index];
	}
	else if ([object isKindOfClass:[NSNumber class]])
	{
		const char *type = [object objCType];
		BOOL isBoolean = CFBooleanGetTypeID() == CFGetTypeID((__bridge_retained CFBooleanRef) object);

		if (strcmp(type, @encode(int)) == 0 || isBoolean)
			resultCode = [self bindInt:[object intValue] atIndex:index];
		else if (strcmp(type, @encode(char)) == 0)
			resultCode = [self bindText:[NSString stringWithFormat:@"%c", [object charValue]] atIndex:index];
		else if (strcmp(type, @encode(long)) == 0)
			resultCode = [self bindLong:[object longValue] atIndex:index];
		else if (strcmp(type, @encode(long long)) == 0)
			resultCode = [self bindLongLong:[object longLongValue] atIndex:index];
		else if (strcmp(type, @encode(float)) == 0)
			resultCode = [self bindDouble:[object floatValue] atIndex:index];
		else if (strcmp(type, @encode(double)) == 0)
			resultCode = [self bindDouble:[object doubleValue] atIndex:index];
		else
			resultCode = SQLITE_MISUSE; // TODO throws type unknown
	}
	else if ([object isKindOfClass:[NSDate class]])
		resultCode = [self bindLong:(long) ([object timeIntervalSince1970] * 1000) atIndex:index];
	else if ([object isKindOfClass:[NSDecimalNumber class]])
		resultCode = [self bindDouble:[object doubleValue] atIndex:index];
	else
		resultCode = SQLITE_MISUSE;

	return resultCode;
}

- (int)intAtIndex:(int)columnIndex
{
	return sqlite3_column_int(_stmt, columnIndex);
}

- (long)longAtIndex:(int)columnIndex
{
	return (long) sqlite3_column_int64(_stmt, columnIndex);
}

- (sqlite3_int64)longLongAtIndex:(int)columnIndex
{
	return sqlite3_column_int64(_stmt, columnIndex);
}

- (double)doubleAtIndex:(int)columnIndex
{
	return sqlite3_column_double(_stmt, columnIndex);
}

- (NSString *)textAtIndex:(int)columnIndex
{
	const char *text = (const char *) sqlite3_column_text(_stmt, columnIndex);
	return text ? [NSString stringWithUTF8String:text] : nil;
}

- (id)objectAtIndex:(int)columnIndex
{
	int columnType = [self columnTypeAtIndex:columnIndex];

	if (columnType == SQLITE_NULL) return nil;
	if (columnType == SQLITE_INTEGER) return @([self longLongAtIndex:columnIndex]);
	if (columnType == SQLITE_FLOAT) return @([self doubleAtIndex:columnIndex]);
	if (columnType == SQLITE_TEXT) return [self textAtIndex:columnIndex];

	return nil;
}

- (int)columnTypeAtIndex:(int)columnIndex
{
	return sqlite3_column_type(_stmt, columnIndex);
}

- (BOOL)isColumnAtIndexNull:(int)columnIndex
{
	return [self columnTypeAtIndex:columnIndex] == SQLITE_NULL;
}

- (NSString *)columnNameAtIndex:(int)columnIndex
{
	const char *name = sqlite3_column_name(_stmt, columnIndex);
	return name ? [NSString stringWithUTF8String:name] : nil;
}

- (int)columnIndexWithName:(NSString *)columnName
{
	return [_columnNameIndexes[columnName] intValue];
}

- (int)step
{
	return sqlite3_step(_stmt);
}

- (int)clearBindings
{
	return sqlite3_clear_bindings(_stmt);
}

- (int)reset
{
	return sqlite3_reset(_stmt);
}

- (int)bindParameterCount
{
	return sqlite3_bind_parameter_count(_stmt);
}

- (int)bindIndexWithName:(NSString *)paramenterName
{
	return sqlite3_bind_parameter_index(_stmt, [paramenterName UTF8String]);
}

- (BOOL)isClosed
{
	return _stmt == NULL;
}

- (int)close:(nullable NSError **)error
{
	int resultCode = sqlite3_finalize(_stmt);

	if (resultCode == SQLITE_OK)
		_stmt = NULL;
	else if (error)
		*error = [self createErrorWithCode:resultCode];

	return resultCode;
}

- (sqlite3_stmt *)handler
{
	return _stmt;
}

- (NSString *)sql
{
	const char *sql = sqlite3_sql(_stmt);
	return sql ? [NSString stringWithUTF8String:sql] : nil;
}

- (NSError *)createErrorWithCode:(int)code
{
	return [self createErrorWithCode:code message:[_database lastErrorMessage]];
}

- (NSError *)createErrorWithCode:(int)code message:(NSString *)message
{
	return [NSError errorWithDomain:@"SQLAid" code:code userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
