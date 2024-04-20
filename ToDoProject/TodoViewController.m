//
//  ViewController.m
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import "TodoViewController.h"
#import "DetailsTaskViewController.h"
#import "TaskDetails.h"
@interface TodoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *emptyImage;
@property (weak, nonatomic) IBOutlet UITableView *toDoTable;
@property NSUserDefaults *userDefault;
@property (weak, nonatomic) IBOutlet UISearchBar *searchTask;
@end

@implementation TodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _toDoTable.delegate = self;
    _toDoTable.dataSource = self;
    _userDefault = [NSUserDefaults standardUserDefaults];
    _todoTasks = [NSMutableArray new];
    _searchTask.delegate = self;
  
    //[_todoTasks ]
   
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    fprintf(stdout , "%s\n" , [text UTF8String]);
    
    
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    fprintf(stdout , "%s\n" , [searchBar.text UTF8String]);
    return YES;

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    fprintf(stdout , "%s\n" , [searchText UTF8String]);
    [self searchText:searchText];
}

-(void) searchText : (NSString *)text{
    

    NSMutableArray *tempSearch = [NSMutableArray new];
    
    for(int i=0 ;i<_tempToDoTsks.count ;i++){
        
        if([[[_tempToDoTsks objectAtIndex:i] title] localizedCaseInsensitiveContainsString:text]){
            [tempSearch addObject:[_tempToDoTsks objectAtIndex:i]];
        }
    }
    
    printf("%d" , _tempToDoTsks.count);
    
    if([text isEqual:@""]){
        _todoTasks = _tempToDoTsks;
    }
    else{
        _todoTasks = tempSearch;
    }
    [_toDoTable reloadData];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    _todoTasks = _tempToDoTsks;
    [_toDoTable reloadData];

}

- (void)viewWillAppear:(BOOL)animated{
    _tempToDoTsks =[NSMutableArray new];
    
    UIViewController * view = self.navigationController.visibleViewController;
    
    view.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                             target:self
                                             action:@selector(navigateToAdd)];
    view.title = @"TODO Page";
    
    
    
    NSData *decoded = [_userDefault objectForKey:@"task"];
    
    
    
    if(decoded != nil)
    {
        
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
        [_todoTasks removeAllObjects];
        [self filter:allTasks];
    }
    
    if(_todoTasks.count==0)
    {
        _emptyImage.image = [UIImage imageNamed:@"to-do-list"];
    }
    else{
        _emptyImage.image = nil;
    }
    
    [_toDoTable reloadData];
    
    
   
}
/*- (void)viewDidAppear:(BOOL)animated{
    NSData *decoded = [_userDefault objectForKey:@"task"];
    
    
    
    if(decoded != nil)
    {
        
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
        [_todoTasks removeAllObjects];
        [self filter:allTasks];
    }
    
    
    [_toDoTable reloadData];
}*/





- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self showAlert:indexPath.row];
        
    }];
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        DetailsTaskViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"details_screen"];
        
        detailsScreen.ref = self;
        
        NSData *decoded = [_userDefault objectForKey:@"task"];
            
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
        
        int index = 0 ;
        for(int i=0 ;i<allTasks.count;i++){
            TaskDetails *details = [_todoTasks objectAtIndex:indexPath.row];
            if([self checkEquality:[allTasks objectAtIndex:i] :details]){
            
                index = i;
                
            }
        }
        
        
        detailsScreen.index = index;
        
        [self.navigationController pushViewController:detailsScreen animated:YES];
        
        
    }];
    
    UISwipeActionsConfiguration *cellConfigration  = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction , editAction]];
    cellConfigration.performsFirstActionWithFullSwipe = YES;
    return cellConfigration;
    
}

-(void) filter : (NSMutableArray *) allTasks {
    for(int i=0 ;i<allTasks.count ;i++){
        TaskDetails *details =[allTasks objectAtIndex:i];
        fprintf(stdout , "%s" ,[[details type] UTF8String]);
        if([[details type] isEqual:@"0"])
        {
            [_todoTasks addObject:[allTasks objectAtIndex:i]];
            [_tempToDoTsks addObject:[allTasks objectAtIndex:i]];
            
        }
    }
    [_toDoTable reloadData];
}

-(void) navigateToAdd {
    
    DetailsTaskViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"details_screen"];
    
    detailsScreen.ref = self;
    detailsScreen.index = -1;
    [self.navigationController pushViewController:detailsScreen animated:YES];
    
    
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIImageView * icon = [cell viewWithTag:0];
    UILabel *taskName = [cell viewWithTag:1];
    
    TaskDetails *details = [_todoTasks objectAtIndex:indexPath.row];

    NSString *levelOfTask = [details level];
    if([levelOfTask isEqual:@"0"])
    {
        icon.image = [UIImage imageNamed:@"green"];
    }
    else if( [levelOfTask isEqual:@"1"]){
        icon.image = [UIImage imageNamed:@"yellow"];
    }
    else{
        icon.image = [UIImage imageNamed:@"red"];

    }
   
    taskName.text = [[_todoTasks objectAtIndex:indexPath.row] title];
    
    
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return _todoTasks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(void) showAlert :(NSInteger) index {
UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message: @"Are you sure you want to delete" preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
  NSData *decoded = [_userDefault objectForKey:@"task"];
      
  NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
  
  for(int i=0 ;i<allTasks.count;i++){
      TaskDetails *details =[_todoTasks objectAtIndex:index];
      if([self checkEquality:[allTasks objectAtIndex:i] :details]){
          [allTasks removeObjectAtIndex:i];
          [_todoTasks removeObjectAtIndex:index];
      }
  }
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:allTasks];
  [_userDefault setObject:data forKey:@"task"];
  if (_todoTasks.count == 0) {
        _emptyImage.image = [UIImage imageNamed:@"to-do-list"];
  }
  [_toDoTable reloadData];
}];

UIAlertAction *cancel  = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
  
}];

[alert addAction:ok];
[alert addAction:cancel];

[self presentViewController:alert animated:YES completion:nil];
}

-(BOOL) checkEquality : (TaskDetails *) task1 : (TaskDetails *)task2 {
    
    
    if([task1.title isEqual:task2.title] && [task1.desc isEqual:task2.desc]
       && [task1.type isEqual:task2.type] && [task1.level isEqual:task2.level]
       &&[task1.date isEqual:task2.date]
       ){
        
        return YES;
    }
    else{
        return NO;
    }
}


//- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate { 
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context { 
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded { 
//    <#code#>
//}

@end
