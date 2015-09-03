//
//  TLVParser.m
//  TLVParser_ObjC
//
//  Created by Fritz on 03.09.15.
//  Copyleft (c) 2015 Fritz
//

#import "TLVParser.h"

@implementation TLVParser

NSData * valueData;
NSData * tagData;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // this used for text
        self.text = [[NSMutableString alloc] init];
        
    }
    return self;
}

// --------------------------------------------------------------------------
// calcTagBytesCount - calculates the number of bytes used by the TAG
// input    bytestream
// returns  the number of bytes
// --------------------------------------------------------------------------

- (int)calcTagBytesCount:(NSData *)aBuf
{
    uint8_t const *bytes = aBuf.bytes;
    if((bytes[0] & 0x1F) == 0x1F)
    { // see subsequent bytes
        int len = 2;
        for(int i=1; i<10; i++)
        {
            if( (bytes[i] & 0x80) != 0x80)
            {
                break;
            }
            len++;
        }
        return len;
    }
    else
    {
        return 1;
    }
}

// --------------------------------------------------------------------------
// isConstructed - checks if it is constructed
// input    bytestream
// returns  True if constructed
// --------------------------------------------------------------------------

- (BOOL)isConstructed:(NSData *) aBuf
{
    uint8_t *bytes = (uint8_t *) aBuf.bytes;
    // 0x20
    //return (bytes[0] & 0b00100000) != 0;
    return (bytes[0] & 0x20) != 0;
}


// --------------------------------------------------------------------------
// calcLengthBytesCount - the number of bytes used by the LENGTH
// input    bytestream
// returns  number of bytes
// --------------------------------------------------------------------------

- (int) calcLengthBytesCount:(NSData *)aBuf
{
    uint8_t const *bytes = aBuf.bytes;
    int len = (int) bytes[0];
    if( (len & 0x80) == 0x80)
    {
        return (int) (1 + (len & 0x7f));
    }
    else
    {
        return 1;
    }
}

// --------------------------------------------------------------------------
// calcDataLength - calculates the LENGTH of the following Value
// input    bytestream
// returns  length or ERROR_LENGTH_TOO_MANY_BYTES if an error occured
// --------------------------------------------------------------------------

- (int) calcDataLength:(NSData *)aBuf
{
    uint8_t const *bytes = aBuf.bytes;
    int length = bytes[0];
    
    if((length & 0x80) == 0x80)
    {
        int numberOfBytes = length & 0x7f;
        if(numberOfBytes>3)
        {
             NSLog(@"ERROR_LENGTH_TOO_MANY_BYTES");
            return ERROR_LENGTH_TOO_MANY_BYTES;
        }
        
        length = 0;
        for(int i=1; i<1+numberOfBytes; i++)
        {
            length = length * 0x100 + bytes[i];
        }
        
    }
    return length;
}

// --------------------------------------------------------------------------
// parseTLVStream   TLV-Parser
// input    bytestream
// input    startlevel
// returns  length
// --------------------------------------------------------------------------

- (int) parseTLVStream:(NSData *)data withLevel:(int)level
{
    unsigned int valueLength = 0;
    
    if ([data length]==0)
    {
        return 1;
    }
    
    while ([data length] > 0)
    {
        int tagBytesCount = [self calcTagBytesCount:data];
        
        //
        NSData * tagData = [data subdataWithRange:NSMakeRange(0, tagBytesCount)];
        BOOL constructed = [self isConstructed:tagData];
        // progress
        data = [data subdataWithRange:NSMakeRange(tagBytesCount, [data length]-tagBytesCount)];
        
        //
        int lengthBytesCount = [self calcLengthBytesCount:data];
        valueLength = [self calcDataLength:data];
        if (valueLength == ERROR_LENGTH_TOO_MANY_BYTES)
        {
            return -1;
        }

        // progress
        data = [data subdataWithRange:NSMakeRange(lengthBytesCount, [data length]-lengthBytesCount)];
        
        
        NSLog(@"level         = %d",level);
        NSLog(@"tagBytesCount      = %d",tagBytesCount);
        NSLog(@"tagData            = %@",tagData);
        NSLog(@"constructed        = %d",constructed);
        NSLog(@"lengthBytesCount   = %d",lengthBytesCount);
        NSLog(@"valueLength        = %d",valueLength);
        
        valueData = [data subdataWithRange:NSMakeRange(0, valueLength)];
        // progress
        data = [data subdataWithRange:NSMakeRange(valueLength, [data length]-valueLength)];
        
        // --------------- display the value
        int i;
        for (i=0;i<level;i++)
        {
            [self.text appendString:@"    "];
        }
        NSString *aStr =[NSString stringWithFormat:@"%@ (%d)",tagData, valueLength];
        [self.text appendString:aStr];
        [self.text appendString:@"\r"];
        // ---------------
        
        
        if (constructed == NO)
        {
            //NSString  *tstr = [HexUtil format:tagData];
            //NSString  *vstr = [HexUtil format:valueData];
            NSMutableString *vstr = [[NSMutableString alloc] initWithCapacity:valueData.length*2];
            uint8_t const *bytes = valueData.bytes;
            NSUInteger max = valueData.length;
            for(NSUInteger i=0; i < max; i++)
            {
                uint8_t b = bytes[i];
                [vstr appendFormat:@"%02X", b];
            }

            
            NSLog(@"valueData          = %@",valueData);
            
            
            // --------------- display the value
            [self.text appendString:@"    "];
            for (i=0;i<level;i++)
            {
                [self.text appendString:@"    "];
            }
            [self.text appendString:vstr];
            [self.text appendString:@"\r"];
            // ---------------
            

        }
        
        if (constructed == YES)
        {
            // recursion
            [self parseTLVStream:valueData withLevel:level+1];
        }
        
    }
    return 1;
}

// --------------------------------------------------------------------------
// displayTLVStream   displays the formatted string
// returns  formatted String
// --------------------------------------------------------------------------

- (NSString *) displayTLVStream
{
    return self.text;
}


@end
