//
//  CIRDatabase.m
//  SQLAid
//
//  Created by Pietro Caselani on 1/11/16.
//  Copyright © 2016 Involves. All rights reserved.
//

#import "CIRDatabase.h"

#import "CIRResultSet.h"
#import "CIRStatement.h"

@interface CIRDatabase ()

@property (assign, nonatomic) sqlite3 *database;
@property (readwrite, nonatomic) NSString *path;

@end

@implementation CIRDatabase

- (instancetype)initWithPath:(NSString *)databasePath
{
	if (self = [super init])
	{
		_path = databasePath;

		_temporaryDirectory = [databasePath stringByDeletingLastPathComponent];
	}

	return self;
}

- (nonnull instancetype)initWithHandler:(nonnull sqlite3 *)handler
{
	if (self = [super init])
		_database = handler;
	
	return self;
}

- (BOOL)open:(NSError **)error
{
	return [self openWithFlags:SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX error:error];
}

- (BOOL)openWithFlags:(int)flags error:(NSError **)error
{
	int rc = sqlite3_open_v2([_path UTF8String], &_database, flags, 0);

	if (rc != SQLITE_OK && error)
	{
		*error = [self createErrorWithCode:rc];
		return NO;
	}

	[self setTemporaryDirectory:_temporaryDirectory];
	
	return YES;
}

- (BOOL)isClosed
{
	return ![self isOpen];
}

- (BOOL)isOpen
{
	return _database > 0;
}

- (void)setTemporaryDirectory:(NSString *)temporaryDirectory
{
	if ([self isOpen])
		sqlite3_temp_directory = (char *) [temporaryDirectory UTF8String];

	_temporaryDirectory = temporaryDirectory;
}

- (CIRStatement *)prepareStatement:(NSString *)sql error:(NSError **)error;
{
	sqlite3_stmt *stmt;

	int resultCode = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, 0);

	if (resultCode != SQLITE_OK)
	{
		if (error)
			*error = [self createErrorWithCode:resultCode];

		return nil;
	}

	return [[CIRStatement alloc] initWithStmt:stmt database:self];
}

- (BOOL)executeStatement:(NSString *)sql error:(NSError **)error;
{
	char *outError;

	int resultCode = sqlite3_exec(_database, [sql UTF8String], 0, 0, &outError);

	if (resultCode != SQLITE_OK)
	{
		if (error)
			*error = [self createErrorWithCode:resultCode message:[NSString stringWithUTF8String:outError]];
		
		return NO;
	}
	
	return YES;
}

- (BOOL)executeUpdate:(NSString *)sql error:(NSError **)error;
{
	return [self executeUpdate:sql withParameters:nil error:error];
}

- (BOOL)executeUpdate:(NSString *)sql withNamedParameters:(NSDictionary<NSString *, id> *)parameters error:(NSError **)error;
{
	return [self executeUpdate:sql withParameters:nil orNamedParameters:parameters error:error];
}

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)parameters error:(NSError **)error;
{
	return [self executeUpdate:sql withParameters:parameters orNamedParameters:nil error:error];
}

- (CIRResultSet *)executeQuery:(NSString *)query error:(NSError **)error;
{
	return [self executeQuery:query withParameters:nil error:error];
}

- (CIRResultSet *)executeQuery:(NSString *)query withNamedParameters:(NSDictionary<NSString *, id> *)parameters error:(NSError **)error;
{
	return [self executeQuery:query withParameters:nil orNamedParameters:parameters error:error];
}

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)parameters error:(NSError **)error;
{
	return [self executeQuery:query withParameters:parameters orNamedParameters:nil error:error];
}

- (BOOL)executeQuery:(NSString *)query error:(NSError **)error each:(void (^)(CIRResultSet *))handler
{
	CIRResultSet *resultSet = [self executeQuery:query error:error];

	while ([resultSet next:error])
		handler(resultSet);
	
	return YES;
}

- (sqlite_int64)lastInsertedId
{
	return sqlite3_last_insert_rowid(_database);
}

- (NSString *)lastErrorMessage
{
	const char *error = sqlite3_errmsg(_database);
	return error ? [NSString stringWithUTF8String:error] : nil;
}

- (sqlite3 *)handler
{
	return _database;
}

- (BOOL)close:(NSError **)error;
{
	int resultCode = sqlite3_close_v2(_database);

	BOOL success = resultCode == SQLITE_OK;

	if (!success && error)
		*error = [self createErrorWithCode:resultCode];

	return success;
}

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters error:(NSError **)error;
{
	CIRStatement *statement = [self compileStatement:sql withParameters:listParameters namedParameters:namedParameters error:error];

	if (statement == nil) return NO;

	if (_willExecuteBlock != nil) _willExecuteBlock(sql);

	int resultCode = [statement step];
	
	if ([[statement close:error] intValue] != SQLITE_OK)
		return NO;

	BOOL success = resultCode == SQLITE_DONE;

	if (!success && error)
		*error = [self createErrorWithCode:resultCode];

	return success;
}

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters error:(NSError **)error;
{
	CIRStatement *statement = [self compileStatement:query withParameters:listParameters namedParameters:namedParameters error:error];

	if (statement == nil) return nil;

	if (_willExecuteBlock != nil) _willExecuteBlock(query);

	return [[CIRResultSet alloc] initWithDatabase:self andStatement:statement];
}

- (CIRStatement *)compileStatement:(NSString *)sql withParameters:(NSArray<id> *)listParameters namedParameters:(NSDictionary<NSString *, id> *)namedParameters error:(NSError **)error;
{
	CIRStatement *statement = [self prepareStatement:sql error:error];

	if (statement == nil) return nil;

	int bindCount = 0, bindTotalCount = [statement bindParameterCount];

	NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) bindTotalCount];
	[values addObjectsFromArray:listParameters];

	for (NSUInteger j = listParameters.count; j < bindTotalCount; ++j)
		values[j] = [NSNull null];

	if ([namedParameters count] > 0)
	{
		int parameterIndex;

		for (NSString *key in [namedParameters allKeys])
		{
			if ((parameterIndex = [statement bindIndexWithName:[@":" stringByAppendingString:key]]) > 0)
				values[(NSUInteger) (parameterIndex - 1)] = namedParameters[key];
		}
	}

	bindCount = (int) values.count;

	for (int i = 0; i < bindCount; i++)
		[statement bindObject:values[(NSUInteger) i] atIndex:i + 1];

	if (bindCount != bindTotalCount)
	{
		[statement close:error];

		if (error)
			*error = [self createErrorWithCode:SQLITE_MISMATCH message:@"The bind count is not correct for the number of variables"];

		return nil;
	}

	return statement;
}

- (NSError *)createErrorWithCode:(int)code
{
	return [self createErrorWithCode:code message:[self lastErrorMessage]];
}

- (NSError *)createErrorWithCode:(int)code message:(NSString *)message
{
	return [NSError errorWithDomain:@"SQLAid" code:code userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
