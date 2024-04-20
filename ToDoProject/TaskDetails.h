//
//  TaskDetails.h
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskDetails : NSObject <NSCoding>

@property NSMutableString *title ;

@property NSMutableString *desc ;

@property NSString *type ;

@property NSString *level ;

@property NSDate *date;


@end

NS_ASSUME_NONNULL_END
