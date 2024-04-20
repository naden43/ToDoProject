//
//  DoneViewController.h
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoneViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>

@property NSMutableArray *doneTasks ;
@end

NS_ASSUME_NONNULL_END
