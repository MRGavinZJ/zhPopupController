//
//  zhSheetView.m
//  zhPopupControllerDemo
//
//  Created by zhanghao on 2016/11/3.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "zhSheetView.h"
#import "zhSheetCell.h"

@interface zhSheetView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) zhSheetViewLayout *zh_layout;
@property (nonatomic, weak, nullable) id <zhSheetViewConfigDelegate> config;

@end

@implementation zhSheetView

- (zhSheetViewLayout *)zh_layout {
    if (!_zh_layout) {
        zhSheetViewLayout *layout = [[zhSheetViewLayout alloc] init];
        if ([self.config respondsToSelector:@selector(layoutOfItemInSheetView:)]) {
             layout = [self.config layoutOfItemInSheetView:self];
        }
        _zh_layout = layout;
    }
    return _zh_layout;
}

- (instancetype)initWithFrame:(CGRect)frame configDelegate:(id<zhSheetViewConfigDelegate>)configDelegate {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor r:240 g:240 b:240];
        self.config = configDelegate;
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.delaysContentTouches = NO;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        _headerLabel = [self labelWithSize:CGSizeMake(frame.size.width, SHEETVIEW_HEADER_HEIGHT)
                                      text:@""
                                 textColor:[UIColor darkGrayColor]
                                      font:[UIFont systemFontOfSize:12]
                                    action:@selector(headerClicked)];
        _tableView.tableHeaderView = _headerLabel;
        
        _footerLabel = [self labelWithSize:CGSizeMake(frame.size.width, SHEETVIEW_FOOTER_HEIGHT)
                                      text:@"取消"
                                 textColor:[UIColor blackColor]
                                      font:[UIFont systemFontOfSize:17]
                                    action:@selector(footerClicked)];
        _footerLabel.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = _footerLabel;
    }
    return self;
}

- (UILabel *)labelWithSize:(CGSize)size text:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font action:(nullable SEL)action {
    UILabel *label = [[UILabel alloc] init];
    label.size = size;
    label.text = text;
    label.textColor = textColor;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:action]];
    return label;
}

- (void)headerClicked {
    if (nil != self.didClickHeader) {
        self.didClickHeader(self);
    }
}

- (void)footerClicked {
    if (nil != self.didClickFooter) {
        self.didClickFooter(self);
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.sectionHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    zhSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sl_sheetCell"];
    if (!cell) {
        zhSheetViewAppearance *sl_appearance = [[zhSheetViewAppearance alloc] init];
        if ([self.config respondsToSelector:@selector(appearanceOfItemInSheetView:)]) {
            sl_appearance = [self.config appearanceOfItemInSheetView:self];
        }
        cell = [[zhSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sl_sheetCell" layout:self.zh_layout appearance:sl_appearance];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    id object = [_models objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSArray class]]) {
        cell.arrays = (NSArray *)object;
    }
    cell.itemClicked = ^(NSInteger index) {
        if ([_delegate respondsToSelector:@selector(sheetView:didSelectItemAtSection:index:)]) {
            [_delegate sheetView:self didSelectItemAtSection:indexPath.row index:index];
        }
    };
    return cell;
}

- (void)setModels:(NSArray *)models {
    _models = models;
    [_tableView reloadData];
}

- (CGFloat)sectionHeight {
    return self.zh_layout.itemEdgeInset.top + self.zh_layout.itemEdgeInset.bottom + self.zh_layout.itemSize.height;
}

- (void)autoresizingFlexibleHeight {
    CGFloat height = self.sectionHeight * _models.count;
    if (!CGRectEqualToRect(_headerLabel.frame, CGRectZero)) {
        height += SHEETVIEW_HEADER_HEIGHT;
    }
    if (!CGRectEqualToRect(CGRectZero, _footerLabel.frame)) {
        height += SHEETVIEW_FOOTER_HEIGHT;
    }
    self.height = _tableView.height = height;
}

@end
