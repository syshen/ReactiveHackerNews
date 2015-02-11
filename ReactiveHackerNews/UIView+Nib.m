//
//  UIView+AMAdditions.m
//  AsiaMiles-Prototype
//
//  Created by syshen on 5/12/14.
//  Copyright (c) 2014 Pebbo. All rights reserved.
//

#import "UIView+Nib.h"

@implementation UIView (Nib)

+ (id) viewFromNib {
  
  __weak id wSelf = self;
    
    // There is a swift bug, compiler will add a package name in front of the class name
    NSString *className = NSStringFromClass(self);
    NSArray *components = [className componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    className = [components lastObject];
    
  return [[[[UINib nibWithNibName:className bundle:[NSBundle bundleForClass:self]] instantiateWithOwner:nil options:nil] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock: ^ (id evaluatedObject, NSDictionary *bindings) {
    return [evaluatedObject isKindOfClass:wSelf];
  }]] lastObject];
  
}

@end
