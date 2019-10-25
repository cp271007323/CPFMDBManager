//
//  CPFMDBManager.h
//  CP_FMDB
//
//  Created by chenp on 2017/8/3.
//  Copyright © 2017年 chenp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@class CPFMDBManager;

typedef void (^CPFMDBManagerBlock)(CPFMDBManager *manger);

typedef enum : NSUInteger {
    /**整型*/
    CPFMDB_INTEGER,
    /**文本*/
    CPFMDB_TEXT,
    /**二进制*/
    CPFMDB_BINARY,
} CPFMDBType;

@interface CPFMDBManager : FMDatabaseQueue

/**
 初始化
 */
+ (instancetype)manager;

/**
 建表
 */
- (void)createTable2DBWithTableName:(NSString *)tableName handle:(CPFMDBManagerBlock)handle;

/**
 添加主键自动增量
 尽量在建表的代码块中添加
 */
- (void)addPrimaryKeyAutoincrementParameter:(NSString *)parameter
                                       type:(CPFMDBType)type;

/**
 添加主键
 尽量在建表的代码块中添加
 */
- (void)addPrimaryKeyParameter:(NSString *)parameter
                          type:(CPFMDBType)type;

/**
 添加自动增量字段
 尽量在建表的代码块中添加
 */
- (void)addAutoincrementParameter:(NSString *)parameter
                             type:(CPFMDBType)type;

/**
 添加不能为空的字段
 尽量在建表的代码块中添加
 */
- (void)addNoNullParameter:(NSString *)parameter
                      type:(CPFMDBType)type;

/**
 添加
 尽量在建表的代码块中添加
 */
- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type;

/**
 添加
 尽量在建表的代码块中添加
 */
- (void)addParameter:(NSString *)parameter
                type:(CPFMDBType)type
        isPrimaryKey:(BOOL)isPrimaryKey
              isNull:(BOOL)isNull
     isAutoincrement:(BOOL)isAutoincrement;

/**
 执行操作
 */
- (void)dealData2TableWithExecute:(NSString *)executeStr;

/**
 插入
 */
- (void)insertToTable:(NSString *)table
                  key:(NSString *)key
                 value:(id)value;

/**
 删除
 */
- (void)deleteToTable:(NSString *)table
                  key:(NSString *)key
                 value:(id)value;

/**
 更新
 */
- (void)updateToTable:(NSString *)table
               newkey:(NSString *)newkey
             newValue:(id)newValue
                bekey:(NSString *)bekey
              beValue:(id)beValue;

/**
 查询表全部
 */
- (NSMutableArray<NSDictionary *> *)queryToTable:(NSString *)table;

/**
 查询具体对应的数据
 */
- (NSMutableArray<NSMutableDictionary *> *)queryToTable:(NSString *)table
                                                    key:(NSString *)key
                                                  value:(NSString *)value;


@end
