//
//  TaskDetails.m
//  ToDoProject
//
//  Created by JETSMobileLabMini3 on 17/04/2024.
//

#import "TaskDetails.h"

@implementation TaskDetails



- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
    
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeObject:self.level forKey:@"level"];
    [coder encodeObject:self.date forKey:@"date"];
    
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder { 
    
    self = [super init];
    
    if(self)
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.desc = [coder decodeObjectForKey:@"desc"];
        self.level = [coder decodeObjectForKey:@"level"];
        self.date = [coder decodeObjectForKey:@"date"];
    }
    return  self;
}

@end
