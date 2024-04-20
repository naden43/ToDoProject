//
//  ViewController.h
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import <UIKit/UIKit.h>
#import "DataSend.h"
@interface TodoViewController : UIViewController < UITableViewDataSource , UITableViewDelegate ,UISearchBarDelegate>

@property NSMutableArray *todoTasks ;

@property NSMutableArray *tempToDoTsks;

@end

