//
//  DetailsTaskViewController.m
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import "DetailsTaskViewController.h"
#import "TodoViewController.h"
#import "TaskDetails.h"
#import "DoneViewController.h"
#import "UserNotifications/UserNotifications.h"
@interface DetailsTaskViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *taskImg;

@property (weak, nonatomic) IBOutlet UITextField *taskTitle;
@property (weak, nonatomic) IBOutlet UITextView *taskDesc;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskLevel;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
@property (weak, nonatomic) IBOutlet UIImageView *attachFile;

@property NSUserDefaults *userDefault;
@property (weak, nonatomic) IBOutlet UIButton *myButton;

@end

@implementation DetailsTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDefault = [NSUserDefaults standardUserDefaults];
    
}


- (void)viewWillAppear:(BOOL)animated{
    _taskDate.minimumDate = [NSDate date];
    if([_ref isMemberOfClass:[TodoViewController class]] && _index == -1){
        
        [_taskType setEnabled:NO forSegmentAtIndex:1];
        [_taskType setEnabled:NO forSegmentAtIndex:2];
        //_myButton.titleLabel = @"Add";
        
        [_myButton setTitle:@"Add" forState:UIControlStateNormal];
        
        
    }
    else if([_ref isMemberOfClass:[DoneViewController class]]){
        [self addDataInFields];
        
        [_taskTitle setEnabled:NO];
        [_taskDesc  setEditable:NO];
        [_taskDate  setEnabled:NO];
        [_taskLevel setEnabled:NO];
        [_taskType setEnabled:NO];
        [_myButton setTitle:@"Back" forState:UIControlStateNormal];
        
    }
    else{ //if([_ref isMemberOfClass:[TodoViewController class]]){
        
        [self addDataInFields];
    }
}

-(void) addDataInFields {
    NSData *decoded = [_userDefault objectForKey:@"task"];
    NSMutableArray <TaskDetails*> * after = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
    
    TaskDetails *taskDetails = [after objectAtIndex:_index];
    
    _taskTitle.text = taskDetails.title;
    NSInteger type = [taskDetails.type integerValue];
    for(int i=0 ;i<type ;i++){
        [_taskType setEnabled:NO forSegmentAtIndex:i];
    }
    [_taskType setSelectedSegmentIndex:type];
    
    NSInteger level = [taskDetails.level integerValue];
    [_taskLevel setSelectedSegmentIndex:level];
    
    _taskDate.date = taskDetails.date;

    
    if(level == 0){
        _taskImg.image = [UIImage imageNamed:@"green"];
    }
    else if(level == 1){
        _taskImg.image = [UIImage imageNamed:@"yellow"];
    }
    else{
        _taskImg.image = [UIImage imageNamed:@"red"];

    }
    _taskDesc.text = taskDetails.desc;
    
    [_myButton setTitle:@"Edit" forState:UIControlStateNormal];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)buttonAction:(id)sender {
    
    if([_taskTitle.text isEqual:@""]|| [_taskDesc.text isEqual: @""]){
        
        [self showAlert];
        
    }
    else{
        if(_index == -1){
            TaskDetails * task = [TaskDetails new];
            
            task.title = _taskTitle.text ;
            task.type = [NSString stringWithFormat:@"%d" , _taskType.selectedSegmentIndex] ;
            task.level = [NSString stringWithFormat:@"%d" , _taskLevel.selectedSegmentIndex] ;
            task.desc = _taskDesc.text;
            task.date= _taskDate.date;
            
            //create a notification content
            UNMutableNotificationContent *notificationContent = [ UNMutableNotificationContent new];
            
            notificationContent.title = @"The Todo Notification";
            notificationContent.body = _taskTitle.text ;
            notificationContent.sound = [UNNotificationSound defaultSound];
            notificationContent.badge  = @1;
            
            NSCalendar *calender = [NSCalendar currentCalendar];
           NSDateComponents * dateComponents =  [calender components:(NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour) fromDate:_taskDate.date];
            
            
            UNCalendarNotificationTrigger *triggerNotification = [ UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
            
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:_taskTitle.text content:notificationContent trigger:triggerNotification];
            
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(!error)
                {
                    printf("scheduled successfully");
                }
                else{
                    printf("%d" , error.code);
                }
                
            }];
            
            
            NSData *decoded = [_userDefault objectForKey:@"task"];
            
            
            if(decoded != nil){
                NSMutableArray <TaskDetails*>*after = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
                [after addObject:task];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:after];
                [_userDefault setObject:data forKey:@"task"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                
                NSMutableArray *tasks = [NSMutableArray new];
                [tasks addObject:task];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tasks];
                [_userDefault setObject:data forKey:@"task"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            
            NSData *decoded = [_userDefault objectForKey:@"task"];
            NSMutableArray <TaskDetails*>*after = [NSKeyedUnarchiver unarchiveObjectWithData:decoded];
            
            [[after objectAtIndex:_index] setTitle: _taskTitle.text];
            [[after objectAtIndex:_index] setDesc:_taskDesc.text];
            [[after objectAtIndex:_index] setDate:_taskDate.date];
            [[after objectAtIndex:_index] setLevel:[NSString stringWithFormat:@"%d" , _taskLevel.selectedSegmentIndex]];
            [[after objectAtIndex:_index] setType:[NSString stringWithFormat:@"%d" , _taskType.selectedSegmentIndex]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:after];
            [_userDefault setObject:data forKey:@"task"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}

-(void) showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message: @"Data Does not Completed , Complete first to add or edit" preferredStyle:UIAlertActionStyleDefault];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *cancel  = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
