//
//  CPFMDBManager.m
//  CP_FMDB
//
//  Created by chenp on 2017/8/3.
//  Copyright © 2017年 chenp. All rights reserved.
//

#import "CPFMDBManager.h"
#import "CPFMDBModel.h"

static NSString *CPParameterKey = @"parameterKey";
static NSString *CPParameterValue = @"parameterValue";

@interface CPFMDBManager ()
@property (nonatomic , strong) NSString         *dbFilePath;
@property (nonatomic , strong) NSMutableDictionary<NSString *,CPFMDBModel *> *parametersDic;
@end

@implementation CPFMDBManager

CPFMDBManager static *manager;

+ (instancetype)manager
{
    @synchronized (self) {
        if (manager == nil) {
            manager = [[CPFMDBManager alloc] init];
            [manager createDB];
        }
    }
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (manager == nil) {
        manager = [[super allocWithZone:zone] init];
    }
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 添加参数
- (void)addPrimaryKeyAutoincrementParameter:(NSString *)parameter
                                       type:(CPFMDBType)type
{
    [self addParameter:parameter
                  type:type
          isPrimaryKey:YES
                isNull:YES
       isAutoincrement:YES];
}

- (void)addPrimaryKeyParameter:(NSString *)parameter
                          type:(CPFMDBType)type
{
    [self addParameter:parameter
                  type:type
          isPrimaryKey:YES
                isNull:YES
       isAutoincrement:NO];
}

- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type
{
    [self addParameter:parameter
                  type:type
          isPrimaryKey:NO
                isNull:NO
       isAutoincrement:NO];
}

- (void)addAutoincrementParameter:(NSString *)parameter
                             type:(CPFMDBType)type
{
    [self addParameter:parameter
                  type:type
          isPrimaryKey:NO
                isNull:NO
       isAutoincrement:YES];
}

- (void)addNoNullParameter:(NSString *)parameter
                      type:(CPFMDBType)type
{
    [self addParameter:parameter
                  type:type
          isPrimaryKey:NO
                isNull:YES
       isAutoincrement:NO];
}

- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type
        isPrimaryKey:(BOOL)isPrimaryKey
              isNull:(BOOL)isNull
     isAutoincrement:(BOOL)isAutoincrement
{
    CPFMDBModel *model = [[CPFMDBModel alloc] init];
    NSMutableString *parameterAddValueStr = [NSMutableString string];
    NSMutableString *parameterTypeValueStr = [NSMutableString string];
    
    [parameterAddValueStr appendFormat:@"'%@' %@",parameter,[self getParameterTypeStr:type]];
    [parameterTypeValueStr appendFormat:@"%@",[self getParameterTypeStr:type]];
    
    if (isNull) {
        NSString *value = @" NOT NULL";
        [parameterAddValueStr appendString:value];
        [parameterTypeValueStr appendString:[value stringByAppendingString:@" default 0"]];
    }
    
    if (isPrimaryKey) {
        NSString *value = @" PRIMARY KEY";
        [parameterAddValueStr appendString:value];
        [parameterTypeValueStr appendString:value];
    }
    
    if (isAutoincrement) {
        NSString *value = @" AUTOINCREMENT";
        [parameterAddValueStr appendString:value];
        [parameterTypeValueStr appendString:value];
    }
    
    [parameterAddValueStr appendString:@","];
    
    model.key = parameter;
    model.keyType = parameterTypeValueStr;
    model.addKeyType = parameterAddValueStr;
    
    [self.parametersDic setObject:model forKey:parameter];
}

- (NSString *)getParameterTypeStr:(CPFMDBType)type
{
    return type == CPFMDB_INTEGER ? @"integer" : type == CPFMDB_TEXT ? @"text" : @"binary";
}

#pragma mark - 创建数据库
- (void)createDB
{
    manager = [CPFMDBManager databaseQueueWithPath:self.dbFilePath];
}

#pragma mark - 建表
- (void)createTable2DBWithTableName:(NSString *)tableName
                             handle:(CPFMDBManagerBlock)handle
                            success:(CPFMDBManagerBlock)success
                               fail:(CPFMDBManagerBlock)fail
{
    //外部添加表字段
    if (handle)
    {
        handle(self);
    }
    
    //表不存在
    if (![self isExitTable:tableName])
    {
        NSString *createTable = [NSString stringWithFormat:@"create table if not exists %@ (%@)",tableName,[self getParameterValue]];
        [manager inDatabase:^(FMDatabase *db) {
            BOOL flag =[db executeUpdate:createTable];
            if(flag)
            {
                NSLog(@"建表成功");
                if (success) {
                    success(manager);
                }
            }
            else
            {
                NSLog(@"建表失败");
                if (fail) {
                    fail(manager);
                }
            }
        }];
        //表建成功，移除模型
        [self.parametersDic removeAllObjects];
    }
    //表存在
    else{
        //判断是否存在新字段
        NSMutableArray<CPFMDBModel *> *models = [self isExitNewKeyForTable:tableName];
        //添加新字段进表
        [self addNewKey2Table:tableName model:models];
        //移除无用模型
        [self.parametersDic removeAllObjects];
    }
}

//判断表是否存在
- (BOOL)isExitTable:(NSString *)tableName
{
    __block BOOL isExit = NO;
    NSString *existsSql = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = '%@'",tableName];
    [manager inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:existsSql];
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            NSLog(@"The table count: %li", count);
            if (count == 1)
            {
                NSLog(@"存在");
                isExit = YES;
            }
        }
    }];
    return isExit;
}

//判断表是否没有新字段
- (NSMutableArray<CPFMDBModel *> *)isExitNewKeyForTable:(NSString *)tableName
{
    __block NSMutableArray *mulArr = [NSMutableArray array];
    __weak typeof(self) weakself = self;
    [manager inDatabase:^(FMDatabase *db) {
        for (CPFMDBModel *model in weakself.parametersDic.allValues) {
            if (![db columnExists:model.key inTableWithName:tableName]) {
                [mulArr addObject:model];
            }
        }
    }];
    return mulArr;
}

//添加新字段
- (void)addNewKey2Table:(NSString *)tableName model:(NSMutableArray<CPFMDBModel *> *)models
{
    [manager inDatabase:^(FMDatabase *db) {
        for (CPFMDBModel *model in models) {
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,model.key,model.keyType];
            BOOL worked = [db executeUpdate:alertStr];
            if(worked)
            {
                NSLog(@"插入新字段成功");
            }else{
                NSLog(@"插入新字段失败");
            }
        }
    }];
}

//获取建表参数值
- (NSMutableString *)getParameterValue
{
    NSMutableString *parameterStr = [NSMutableString string];
    for (NSString *key in self.parametersDic) {
        CPFMDBModel *model = self.parametersDic[key];
        [parameterStr appendFormat:@"%@",model.addKeyType];
    }
    [parameterStr deleteCharactersInRange:NSMakeRange(parameterStr.length - 1, 1)];
    return parameterStr;
}

- (void)insertToTable:(NSString *)table key:(NSString *)key value:(id)value
{
    NSString *str = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)",table,key];
    
    [manager inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:str,value];
        if (flag)
        {
            NSLog(@"插入成功");
        }
        else
        {
            NSLog(@"插入失败");
        }
    }];
}

- (void)deleteToTable:(NSString *)table key:(NSString *)key value:(id)value
{
    NSString *str = [NSString stringWithFormat:@"delete from %@ where %@ = ?",table,key];
    
    [manager inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:str,value];
        if (flag)
        {
            NSLog(@"删除成功");
        }
        else
        {
            NSLog(@"删除失败");
        }
    }];
}

- (void)updateToTable:(NSString *)table
               newkey:(NSString *)newkey
             newValue:(id)newValue
                bekey:(NSString *)bekey
              beValue:(id)beValue
{
    NSString *str = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",table,newkey,bekey];
    
    [manager inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:str,newValue,beValue];
        if (flag)
        {
            NSLog(@"更新成功");
        }
        else
        {
            NSLog(@"更新失败");
        }
    }];
}

- (NSMutableArray<id> *)queryTheDatabaseForSeveralTables
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbFilePath];

    if ([db open])
    {
        // 根据请求参数查询数据
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];;
        
        NSMutableArray *tableNames = [NSMutableArray array];
        // 遍历查询结果
        while (resultSet.next) {
            
            NSString *str1 = [resultSet stringForColumnIndex:1];
            [tableNames addObject:str1];
            
        }
        [tableNames removeObject:@"sqlite_sequence"];
        return tableNames;
    }
    return 0;
}

- (BOOL)deleteTheDatabaseForTablesWithTableName:(NSString *)tableName
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbFilePath];
    
    if ([db open])
    {
        // 根据请求参数查询数据
        BOOL flag = [db executeUpdate:[NSString stringWithFormat:@"drop table %@;",tableName]];
        if (flag)
        {
            NSLog(@"表 %@ 删除成功",tableName);
            return YES;
        }
        else
        {
            NSLog(@"表 %@ 删除失败",tableName);
            return NO;
        }
    }
    NSLog(@"表- %@ 删除失败",tableName);
    return NO;
}

- (NSMutableArray<NSMutableDictionary *> *)queryToTable:(NSString *)table
{
    NSString *str = [NSString stringWithFormat:@"select * from %@",table];
    
    NSMutableArray<NSMutableDictionary *> *objects = [NSMutableArray array];
    
    [manager inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:str];
        
        //获取表的所有键值
        NSMutableArray<NSString *> *keys = [NSMutableArray array];
        for (int i = 0; i < [resultSet columnCount]; i++)
        {
            [keys addObject:[resultSet columnNameForIndex:i]];
        }
        
        //遍历所有键值取值
        while ([resultSet next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = [resultSet objectForColumnName:obj];
                [dic setObject:value forKey:obj];
            }];
            [objects addObject:dic];
        }
    }];
    
    return objects;
}

- (NSMutableArray<NSMutableDictionary *> *)queryToTable:(NSString *)table
                                                    key:(NSString *)key
                                                  value:(NSString *)value
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where %@ = ?",table,key];
    
    NSMutableArray<NSMutableDictionary *> *objects = [NSMutableArray array];
    
    [manager inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:str,value];
        
        //获取表的所有键值
        NSMutableArray<NSString *> *keys = [NSMutableArray array];
        for (int i = 0; i < [resultSet columnCount]; i++)
        {
            [keys addObject:[resultSet columnNameForIndex:i]];
        }
        
        //遍历所有键值取值
        while ([resultSet next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = [resultSet objectForColumnName:obj];
                [dic setObject:value forKey:obj];
            }];
            [objects addObject:dic];
        }
    }];
    
    return objects;
}

#pragma mark - 数据操作
- (void)dealData2TableWithExecute:(NSString *)executeStr;
{
    [manager inDatabase:^(FMDatabase *db) {
        [db executeUpdate:executeStr];
    }];
}


#pragma mark - get
-(NSMutableDictionary<NSString *,CPFMDBModel *> *)parametersDic{
    if (_parametersDic == nil) {
        _parametersDic = [NSMutableDictionary dictionary];
    }
    return _parametersDic;
}

-(NSString *)dbFilePath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",NSStringFromClass([self class])]];
}

@end
