//
//  InprogressViewController.m
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import "InprogressViewController.h"
#import "TaskDetails.h"
#import "DetailsTaskViewController.h"
@interface InprogressViewController ()
@property NSUserDefaults *userDefault;
@property (weak, nonatomic) IBOutlet UITableView *inProgressTable;
@property Boolean startFilter ;
@property NSMutableArray *lowTasks;
@property NSMutableArray *highTasks;
@property NSMutableArray *mediumTasks;
@end

@implementation InprogressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inProgressTable.delegate = self;
    _inProgressTable.dataSource = self;
    _userDefault = [NSUserDefaults standardUserDefaults];
    _inProgressTasks = [NSMutableArray new];
    _startFilter = FALSE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)filterButton:(id)sender {
    _startFilter = !_startFilter;
    
    if(_startFilter){
        [self filterLists];
    }
    
    [_inProgressTable reloadData];
}

-(void) filterLists {
    _lowTasks = [NSMutableArray new];
    _mediumTasks = [NSMutableArray new];
    _highTasks =[NSMutableArray new];
    
    for(int i=0 ;i<_inProgressTasks.count;i++){
        TaskDetails *task = [_inProgressTasks objectAtIndex:i];
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
        return @"In progress Tasks";
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
        
        for(int i=0 ;i<_inProgressTasks.count ;i++){
            
            if([self checkEquality:[_inProgressTasks objectAtIndex:i] : details]){
                selectedIndex = i;
                break;
            }
        }
        
    }
    else{
        selectedIndex = indexPath.row;
    }
    
    
   UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
       
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
       [_inProgressTable reloadData];
       
       
   }];
   
   UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
       DetailsTaskViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"details_screen"];
       
       detailsScreen.ref = self;
       NSData *decoded = [_userDefault objectForKey:@"task"];
           
       NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
       
       int index = 0 ;
       for(int i=0 ;i<allTasks.count;i++){
           TaskDetails *details = [_inProgressTasks objectAtIndex:selectedIndex];
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
- (void)viewWillAppear:(BOOL)animated{
    
    UIViewController * view = self.navigationController.visibleViewController;
    
    view.navigationItem.rightBarButtonItem.hidden = YES;
    
    view.title = @"In progress Page";
 
    
    NSData *decoded = [_userDefault objectForKey:@"task"];
    
    
    
    if(decoded != nil)
    {
        
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
        [_inProgressTasks removeAllObjects];
        [self filter:allTasks];
    }
    
    if(_startFilter){
        [self filterLists];
    }
    
    [_inProgressTable reloadData];
    
    

}

-(void) filter : (NSMutableArray *) allTasks {
    for(int i=0 ;i<allTasks.count ;i++){
        TaskDetails *details =[allTasks objectAtIndex:i];
        fprintf(stdout , "%s" ,[[details type] UTF8String]);
        if([[details type] isEqual:@"1"])
        {
            [_inProgressTasks addObject:[allTasks objectAtIndex:i]];
            
        }
    }
    [_inProgressTable reloadData];
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
        details = [_inProgressTasks objectAtIndex:indexPath.row];
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
        return _inProgressTasks.count;
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
-(void) showAlert :(NSInteger) index {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message: @"Are you sure you want to delete" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSData *decoded = [_userDefault objectForKey:@"task"];
            
        NSMutableArray *allTasks = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
       
        
        for(int i=0 ;i<allTasks.count;i++){
            TaskDetails *details =[_inProgressTasks objectAtIndex:index];
            if([self checkEquality:[allTasks objectAtIndex:i] :details]){
                [allTasks removeObjectAtIndex:i];
                [_inProgressTasks removeObjectAtIndex:index];
            }
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:allTasks];
        [_userDefault setObject:data forKey:@"task"];
        [_inProgressTable reloadData];
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
