//
//  main.m
//  ParseTLV_ObjC
//
//  Created by Fritz on 03.09.15.
//  Copyleft (c) 2015 Fritz
//

#import <Foundation/Foundation.h>
#import "TLVParser.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"TLV Parser in Objective-C");
        
        
        const unsigned char bytes[] =
        {
            0xe1,0x35,0x9f,0x1e,0x08,0x31,0x36,0x30,0x32,0x31,0x34,0x33,0x37,0xef,0x12,0xdf,
            0x0d,0x08,0x4d,0x30,0x30,0x30,0x2d,0x4d,0x50,0x49,0xdf,0x7f,0x04,0x31,0x2d,0x32,
            0x32,0xef,0x14,0xdf,0x0d,0x0b,0x4d,0x30,0x30,0x30,0x2d,0x54,0x45,0x53,0x54,0x4f,
            0x53,0xdf,0x7f,0x03,0x36,0x2d,0x35 };
        
        NSData *dataTextField = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        NSLog(@"%@", dataTextField);
        

        // create a TLVParser
        TLVParser *parser = [[TLVParser alloc] init];
            
        // parse
        [parser parseTLVStream:dataTextField withLevel:0];
        
        // display tree
        NSLog(@"\n%@\n",[parser displayTLVStream]);
 

    }
    return 0;
}
