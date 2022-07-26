//
//  EaseChatRecordImageVideoViewController.m
//  Pods
//
//  Created by liu001 on 2022/7/16.
//

#import "EaseChatRecordImageVideoViewController.h"
#import "EaseNoDataPlaceHolderView.h"
#import "EaseRecordImageVideoCell.h"
#import "EaseHeaders.h"
#import "EMImageBrowser.h"

@interface EaseChatRecordImageVideoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSString *moreMsgId;
@property (nonatomic, strong) EaseNoDataPlaceHolderView *noDataPromptView;

@end

static NSString *imageVideoCellIndentifier = @"imageVideoCellIndentifier";

@implementation EaseChatRecordImageVideoViewController

- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        _msgQueue = dispatch_queue_create("emmessagerecord.com", NULL);
        _moreMsgId = @"";
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.noDataPromptView];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(60.0);
        make.centerX.left.right.equalTo(self.view);
    }];
    
    [self loadDatas];
}

- (void)loadDatas {
    
//    if ([EaseIMKitOptions sharedOptions].isPriorityGetMsgFromServer) {
//        EMConversation *conversation = self.conversation;
//        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
//            [self.conversation loadMessagesStartFromId:self.moreMsgId count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
//                [self loadMessages:aMessages withError:aError];
//            }];
//         }];
//    } else {
//        [self.conversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
//            [self loadMessages:aMessages withError:aError];
//        }];
//    }
    
    [self.conversation loadMessagesStartFromId:self.moreMsgId count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
        [self loadMessages:aMessages withError:aError];
    }];

}


- (void)loadMessages:(NSArray *)aMessages  withError:(EMError *)aError {
    if (!aError && [aMessages count] > 0) {
        dispatch_async(self.msgQueue, ^{
            NSMutableArray *msgArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [aMessages count]; i++) {
                EMChatMessage *msg = aMessages[i];
                if(msg.body.type == EMMessageBodyTypeImage) {
                    [msgArray addObject:msg];
                }
                
                if(msg.body.type == EMMessageBodyTypeVideo) {
                    [msgArray addObject:msg];
                }

            }
            
            EaseIMKit_WS
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:msgArray];
                [weakSelf.collectionView reloadData];
                
                weakSelf.noDataPromptView.hidden = weakSelf.dataArray.count > 0 ? YES : NO;
            });
        });
    }
    
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseRecordImageVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageVideoCellIndentifier forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    [cell updateWithObj:obj];
    
    return cell;
}

- (void)messageEventOperation:(EMChatMessage *)aMessage {
    EaseIMKit_WS
        
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aMessage progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadImageFail", nil)];
        } else {
            if (message.direction == EMMessageDirectionReceive && !message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            
            NSString *localPath = [(EMImageMessageBody *)message.body localPath];
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            if (image) {
                [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self];
            } else {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchImageFail", nil)];
            }
        }
    }];
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EMChatMessage *msg = [self.dataArray objectAtIndex:indexPath.row];
    [self messageEventOperation:msg];
}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseRecordImageVideoCell class] forCellWithReuseIdentifier:imageVideoCellIndentifier];
        
        _collectionView.backgroundColor = EaseIMKit_ViewBgBlackColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat itemWidth = (EaseIMKit_ScreenWidth - 10.0 * 3 - 16.0 * 2)/4.0;
    CGFloat itemHeight = itemWidth;
    
    flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 16.0, 10.0, 16.0);
    
    return flowLayout;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"ji_search_nodata"]];
        _noDataPromptView.prompt.text = @"搜索无结果";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

@end
