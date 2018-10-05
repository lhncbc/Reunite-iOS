//
//  BTSplitViewDefinition.h
//  ReUnite + TriagePic
//

//

#import <Foundation/Foundation.h>

#define SPLIT_VIEW_BACK_NOTIFICATION @"SPLIT_VIEW_BACK_NOTIFICATION"

#define SPLIT_VIEW_ACTION_MASTER @"SPLIT_VIEW_ACTION_MASTER"
#define SPLIT_VIEW_ACTION_DETAIL @"SPLIT_VIEW_ACTION_DETAIL"

#define SPLIT_KEY_ACTION_TYPE @"SPLIT_KEY_ACTION_TYPE"
#define SPLIT_KEY_ANIMATE @"SPLIT_KEY_ANIMATE"
#define SPLIT_KEY_VIEW_CONTROLLER @"SPLIT_KEY_VIEW_CONTROLLER"

typedef enum {
    ActionTypePush,
    ActionTypePop,
    ActionTypePushIfNotExist,
    ActionTypePopThenPush
}ActionType;

@interface BTSplitViewDefinition : NSObject

@end
