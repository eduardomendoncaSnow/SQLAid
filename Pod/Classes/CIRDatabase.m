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

@property(assign, nonatomic) sqlite3 *database;
@property(readwrite, nonatomic) NSString *path;

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

- (void)open
{
	[self openWithFlags:SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX];
}

- (void)openWithFlags:(int)flags
{
	int rc = sqlite3_open_v2([_path UTF8String], &_database, flags, 0);

	if (rc != SQLITE_OK)
	{
		@throw [NSException exceptionWithName:@"Can't open database" reason:[self lastErrorMessage] userInfo:nil];
	}

	[self setTemporaryDirectory:_temporaryDirectory];
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
	{
		sqlite3_temp_directory = (char *) [temporaryDirectory UTF8String];
	}

	_temporaryDirectory = temporaryDirectory;
}

- (CIRStatement *)prepareStatement:(NSString *)sql
{
	sqlite3_stmt *stmt;

	int resultCode = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, 0);

	if (resultCode != SQLITE_OK)
	{
		@throw [NSException exceptionWithName:[NSString stringWithFormat:@"Can't prepare statement %@", sql] reason:[self lastErrorMessage] userInfo:nil];
	}

	return [[CIRStatement alloc] initWithStmt:stmt];
}

- (void)executeStatement:(NSString *)sql
{
	char *outError;

	int resultCode = sqlite3_exec(_database, [sql UTF8String], 0, 0, &outError);

	if (resultCode != SQLITE_OK)
	{
		@throw [NSException exceptionWithName:[NSString stringWithFormat:@"Can't execute statement %@", sql] reason:[NSString stringWithUTF8String:outError] userInfo:nil];
	}
}

- (BOOL)executeUpdate:(NSString *)sql
{
	return [self executeUpdate:sql withParameters:nil];
}

- (BOOL)executeUpdate:(NSString *)sql withNamedParameters:(NSDictionary<NSString *, id> *)parameters
{
	return [self executeUpdate:sql withParameters:nil orNamedParameters:parameters];
}

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)parameters
{
	return [self executeUpdate:sql withParameters:parameters orNamedParameters:nil];
}

- (CIRResultSet *)executeQuery:(NSString *)query
{
	return [self executeQuery:query withParameters:nil];
}

- (CIRResultSet *)executeQuery:(NSString *)query withNamedParameters:(NSDictionary<NSString *, id> *)parameters
{
	return [self executeQuery:query withParameters:nil orNamedParameters:parameters];
}

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)parameters
{
	return [self executeQuery:query withParameters:parameters orNamedParameters:nil];
}

- (void)executeQuery:(NSString *)query each:(void (^)(CIRResultSet *))handler
{
	CIRResultSet *resultSet = [self executeQuery:query];

	while ([resultSet next])
		handler(resultSet);
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

- (BOOL)close
{
	return sqlite3_close_v2(_database) == SQLITE_OK;
}

- (BOOL)executeUpdate:(NSString *)sql withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters
{
	CIRStatement *statement = [self compileStatement:sql withParameters:listParameters namedParameters:namedParameters];

	if (_willExecuteBlock != nil) _willExecuteBlock(sql);

	int resultCode = [statement step];

	[statement close];

	return resultCode == SQLITE_DONE;
}

- (CIRResultSet *)executeQuery:(NSString *)query withParameters:(NSArray<id> *)listParameters orNamedParameters:(NSDictionary<NSString *, id> *)namedParameters
{
	CIRStatement *statement = [self compileStatement:query withParameters:listParameters namedParameters:namedParameters];

	if (_willExecuteBlock != nil) _willExecuteBlock(query);

	return [[CIRResultSet alloc] initWithDatabase:self andStatement:statement];
}

- (CIRStatement *)compileStatement:(NSString *)sql withParameters:(NSArray<id> *)listParameters namedParameters:(NSDictionary<NSString *, id> *)namedParameters
{
	CIRStatement *statement = [self prepareStatement:sql];

	int bindCount = 0, bindTotalCount = [statement bindParameterCount];

	NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) bindTotalCount];
	[values addObjectsFromArray:listParameters];

	if ([namedParameters count] > 0)
	{
		int parameterIndex;

		for (NSString *key in [namedParameters allKeys])
		{
			if ((parameterIndex = [statement bindIndexWithName:[@":" stringByAppendingString:key]]) > 0)
				[values insertObject:namedParameters[key] atIndex:(NSUInteger) (parameterIndex - 1)];
		}
	}

	bindCount = (int) values.count;

	for (int i = 0; i < bindCount; i++)
	{
		[statement bindObject:values[(NSUInteger) i] atIndex:i + 1];
	}

	if (bindCount != bindTotalCount)
	{
		[statement close];

		@throw [NSException exceptionWithName:@"Bind count invalid" reason:@"The bind count is not correct for the number of variables" userInfo:nil];
	}

	return statement;
}

@end
