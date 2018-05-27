//
//  Example.m
//  Example
//
//  Created by Yoshimasa Niwa on 5/26/18.
//  Copyright © 2018 Yoshimasa Niwa. All rights reserved.
//

#import "Example.h"
#import "Example-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Example

// This method decleration should be warned by the example Clang analyzer checker.
- (void)_methodMayConflictWithAppleInternalName
{
    // Meow.
}

// This method decleration should note be warned.
- (void)_method_MayNotConflictWithAPpleInternalName
{
    // Meow.
}

- (void)method
{
    // Use Swift class.
    __unused ExampleSwiftClass *example = [[ExampleSwiftClass alloc] init];
}

@end

NS_ASSUME_NONNULL_END
