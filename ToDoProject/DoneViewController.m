//
//  DoneViewController.m
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import "DoneViewController.h"
#import "TaskDetails.h"
#import "DetailsTaskViewController.h"
@interface DoneViewController ()
@property (weak, nonatomic) IBOutlet UITableView *doneTable;
@property NSUserDefaults *userDefault;
@property Boolean startFilter ;
@property NSMutableArray *lowTasks;
@property NSMutableArray *highTasks;
@property NSMutableArray *mediumTasks;

@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _doneTable.delegate = self;
    _doneTable.dataSource = self;
    _userDefault = [NSUserDefaults standardUserDefaults];
    _doneTasks = [NSMutableArray new];
    _startFilter = FALSE;    
    
}




- (void)viewWillAppear:(BOOL)animated{
    UIViewController * view = self.navigationController.visibleViewController;
    
    view.navigationItem.rightBarButtonItem.hidden = YES; 
    
    view.title = @"Done Page";

    NSData *decoded = [_userDefault objectForKey:@"task"];
    
    
    
    if(decoded != nil)
    {
        
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
        [_doneTasks removeAllObjects];
        [self filter:allTasks];
    }
    
    
    [_doneTable reloadData];
    
}

-(void) filter : (NSMutableArray *) allTasks {
    for(int i=0 ;i<allTasks.count ;i++){
        TaskDetails *details =[allTasks objectAtIndex:i];
        fprintf(stdout , "%s" ,[[details type] UTF8String]);
        if([[details type] isEqual:@"2"])
        {
            [_doneTasks addObject:[allTasks objectAtIndex:i]];
            
        }
    }
    [_doneTable reloadData];
}
//

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(_startFilter){
        if(section == 0){
            return @"Low";
        }
        else if (section == 1)
        {
            return @"Medium";
        }
        else{
            return @"High";
        }
    }
    else{
        return @"Done Tasks";
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIImageView * icon = [cell viewWithTag:0];
    UILabel *taskName = [cell viewWithTag:1];
    
    TaskDetails *details ;
    
    if(_startFilter){
        if(indexPath.section == 0){
            details = [_lowTasks objectAtIndex:indexPath.row];
        }
        else if(indexPath.section == 1)
        {
            details = [_mediumTasks objectAtIndex:indexPath.row];

        }
        else{
            details = [_highTasks objectAtIndex:indexPath.row];

        }
    }
    else{
        details = [_doneTasks objectAtIndex:indexPath.row];
    }

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
   
    taskName.text = [details title];
    
    
    return cell;
    
}
//
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    if(_startFilter){
        if(section == 0){
            return _lowTasks.count;
        }
        else if (section == 1)
        {
            return _mediumTasks.count;
        }
        else{
            return _highTasks.count;
        }
    }
    else{
        return _doneTasks.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_startFilter){
        return 3;
    }
    else{
        return 1;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSInteger selectedIndex = 0 ;
    if(_startFilter)
    {
     
        TaskDetails *details ;
        if(indexPath.section == 0){
            details = [_lowTasks objectAtIndex:indexPath.row];
        }
        else if(indexPath.section == 1)
        {
            details = [_mediumTasks objectAtIndex:indexPath.row];
        }
        else{
            details = [_highTasks objectAtIndex:indexPath.row];
        }
        
        for(int i=0 ;i<_doneTasks.count ;i++){
            
            if([self checkEquality:[_doneTasks objectAtIndex:i] : details]){
                selectedIndex = i;
                break;
            }
        }
        
    }
    else{
        selectedIndex = indexPath.row;
    }
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
//        NSData *decoded = [_userDefault objectForKey:@"task"];
//            
//        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
//        
//        for(int i=0 ;i<allTasks.count;i++){
//            
//            TaskDetails *details =[_doneTasks objectAtIndex:indexPath.row];
//            if([[allTasks objectAtIndex:i] title] == details.title){
//                [allTasks removeObjectAtIndex:i];
//                [_doneTasks removeObjectAtIndex:indexPath.row];
//                
//            }
//        }
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:allTasks];
//        [_userDefault setObject:data forKey:@"task"];
//        [_doneTable reloadData];
//        
        
        [self showAlert:selectedIndex];
        if(_startFilter)
        {
            if(indexPath.section == 0){
                 [_lowTasks removeObjectAtIndex:indexPath.row];
            }
            else if(indexPath.section == 1)
            {
                [_mediumTasks removeObjectAtIndex:indexPath.row];
            }
            else{
                [_highTasks removeObjectAtIndex:indexPath.row];
            }
            
        }
        [_doneTable reloadData];
      
    }];
    
    
    
    UISwipeActionsConfiguration *cellConfigration  = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    cellConfigration.performsFirstActionWithFullSwipe = YES;
    return cellConfigration;
    
}


- (IBAction)filterButton:(id)sender {
    
    _startFilter = !_startFilter;
    
    if(_startFilter){
        [self filterLists];
    }
    
    [_doneTable reloadData];
    
}


-(void) filterLists {
    _lowTasks = [NSMutableArray new];
    _mediumTasks = [NSMutableArray new];
    _highTasks =[NSMutableArray new];
    
    for(int i=0 ;i<_doneTasks.count;i++){
        TaskDetails *task = [_doneTasks objectAtIndex:i];
        if([task.level isEqual:@"0"]){
            [_lowTasks addObject:task];
        }
        else if([task.level isEqual:@"1"])
        {
            [_mediumTasks addObject:task];
        }
        else{
            [_highTasks addObject:task];
        }
    }
}


-(void) showAlert :(NSInteger) index {
UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message: @"Are you sure you want to delete" preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
  NSData *decoded = [_userDefault objectForKey:@"task"];
      
  NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
  
  for(int i=0 ;i<allTasks.count;i++){
      TaskDetails *details =[_doneTasks objectAtIndex:index];
      if([self checkEquality:[allTasks objectAtIndex:i] :details]){
          printf("here");
          [allTasks removeObjectAtIndex:i];
          [_doneTasks removeObjectAtIndex:index];
      }
  }
    printf("number = %d" , allTasks.count);
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:allTasks];
  [_userDefault setObject:data forKey:@"task"];
  [_doneTable reloadData];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger selectedIndex = 0 ;
    if(_startFilter)
    {
     
        TaskDetails *details ;
        if(indexPath.section == 0){
            details = [_lowTasks objectAtIndex:indexPath.row];
        }
        else if(indexPath.section == 1)
        {
            details = [_mediumTasks objectAtIndex:indexPath.row];
        }
        else{
            details = [_highTasks objectAtIndex:indexPath.row];
        }
        
        for(int i=0 ;i<_doneTasks.count ;i++){
            
            if([self checkEquality:[_doneTasks objectAtIndex:i] : details]){
                selectedIndex = i;
                break;
            }
        }
        
    }
    else{
        selectedIndex = indexPath.row;
    }
    DetailsTaskViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"details_screen"];
    
    detailsScreen.ref = self;
    NSData *decoded = [_userDefault objectForKey:@"task"];
        
    NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
    
    int index = 0 ;
    for(int i=0 ;i<allTasks.count;i++){
        TaskDetails *details = [_doneTasks objectAtIndex:selectedIndex];
        if([self checkEquality:[allTasks objectAtIndex:i] :details]){
        
            index = i;
            
        }
    }
    
    detailsScreen.index = index;
    
    [self.navigationController pushViewController:detailsScreen animated:YES];
    
}
//
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
