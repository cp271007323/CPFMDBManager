//
//  CPFMDBManager.h
//  CP_FMDB
//
//  Created by lk03 on 2017/8/3.
//  Copyright © 2017年 lk06. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>


typedef enum : NSUInteger {
    /**整型*/
    CPFMDB_INTEGER,
    /**文本*/
    CPFMDB_TEXT,
    /**二进制*/
    CPFMDB_BINARY,
} CPFMDBType;

@interface CPFMDBManager : FMDatabaseQueue

+ (instancetype)manager;

/**添加主键自动增量*/
- (void)addPrimaryKeyAutoincrementParameter:(NSString *)parameter
                                       type:(CPFMDBType)type;

/**添加主键*/
- (void)addPrimaryKeyParameter:(NSString *)parameter
                          type:(CPFMDBType)type;

/**添加自动增量字段*/
- (void)addAutoincrementParameter:(NSString *)parameter
                             type:(CPFMDBType)type;

/**添加不能为空的字段*/
- (void)addNoNullParameter:(NSString *)parameter
                      type:(CPFMDBType)type;

/**添加*/
- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type;

/**添加*/
- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type
        isPrimaryKey:(BOOL)isPrimaryKey
              isNull:(BOOL)isNull
     isAutoincrement:(BOOL)isAutoincrement;

/**建表*/
- (void)createTable2DBWithTableName:(NSString *)tableName;

/**删表*/
- (void)dealData2TableWithExecute:(NSString *)executeStr;



/**插入*/
- (void)insertToTable:(NSString *)table
                  key:(NSString *)key
                 value:(id)value;

/**删除*/
- (void)deleteToTable:(NSString *)table
                  key:(NSString *)key
                 value:(id)value;

/**更新*/
- (void)updateToTable:(NSString *)table
               newkey:(NSString *)newkey
             newValue:(id)newValue
                bekey:(NSString *)bekey
              beValue:(id)beValue;

/**查询*/
- (NSMutableArray<NSDictionary *> *)queryToTable:(NSString *)table;

- (NSMutableArray<NSMutableDictionary *> *)queryToTable:(NSString *)table
                                                    key:(NSString *)key
                                                  value:(NSString *)value;


@end
