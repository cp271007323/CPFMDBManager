//
//  ViewController.m
//  CPFMDBManager_Demo
//
//  Created by 陈平 on 2019/9/10.
//  Copyright © 2019 GraffitiBoard. All rights reserved.
//

#import "ViewController.h"
#import "CPFMDBManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建数据库
    
    //创建数据库
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id15" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time15" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image15" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"GXMB1" handle:nil];
    
    
    //创建数据库
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time2" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image2" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"GXMB2" handle:nil];
    
    //创建数据库
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id3" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time3" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image3" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"GXMB3" handle:nil];
    
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id4" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time4" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image4" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"GXMB4" handle:nil];
    
    
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id4" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time4" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image4" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"GXMB5" handle:nil];
    
    
    [[CPFMDBManager manager] addPrimaryKeyAutoincrementParameter:@"id4" type:CPFMDB_INTEGER];
    [[CPFMDBManager manager] addParameter:@"id_time4" type:CPFMDB_TEXT];
    [[CPFMDBManager manager] addParameter:@"image4" type:CPFMDB_BINARY];
    [[CPFMDBManager manager] createTable2DBWithTableName:@"旅游" handle:nil];
    
    
    [[CPFMDBManager manager] deleteTheDatabaseForTablesWithTableName:@"旅游"];
    
    NSLog(@"%@",NSHomeDirectory());
    [[[CPFMDBManager manager] queryTheDatabaseForSeveralTables] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",[[CPFMDBManager manager] queryToTable:obj]);
    }];
    
}


@end
