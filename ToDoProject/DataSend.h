//
//  DataSend.h
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import <Foundation/Foundation.h>
#import "TaskDetails.h"
NS_ASSUME_NONNULL_BEGIN

@protocol DataSend <NSObject>

@property int status;
-(void) sendData : (TaskDetails *) task ;

@end

NS_ASSUME_NONNULL_END
