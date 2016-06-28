//
//  IOSViewController.m
//  Gank
//
//  Created by 朱安智 on 16/6/28.
//  Copyright © 2016年 朱安智. All rights reserved.
//

#import "IOSViewController.h"
#import "GankResponse.h"
#import "IOSTableViewCell.h"

#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking/AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>

@interface IOSViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray<GankResult *> *entitys;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation IOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.page = 1;
    self.entitys = NSMutableArray.new;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEntityFromNet {
    self.task = [AFHTTPSessionManager.manager GET:[NSString stringWithFormat:@"http://gank.io/api/data/iOS/20/%@", @(self.page)] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"ios progress:%@", [downloadProgress localizedAdditionalDescription]);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_footer endRefreshing];
        GankResponse *response = [[GankResponse alloc] initWithResponse:responseObject];
        NSArray *results = [response resultFromResponse];
        if (results) {
            [self.entitys addObjectsFromArray:results];
            [self.tableView reloadData];
            self.page ++;
        } else {
            NSLog(@"Empty results from ios:%@", responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"get result from ios error:%@", error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
        self.task = nil;
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - TableView

- (void)configureTableView {
    self.tableView = UITableView.new;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    Class ios = IOSTableViewCell.class;
    [self.tableView registerClass:ios forCellReuseIdentifier:NSStringFromClass(ios)];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getEntityFromNet)];
    [self.tableView.mj_footer beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entitys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IOSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(IOSTableViewCell.class) forIndexPath:indexPath];
    GankResult *entity = self.entitys[indexPath.row];
    [cell configureCellWithEntity:entity];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GankResult *entity = self.entitys[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(IOSTableViewCell.class) configuration:^(id cell) {
        IOSTableViewCell *mycell = cell;
        [mycell configureCellWithEntity:entity];
    }];
}

@end