#import "NSData+AES.h"

#import <CommonCrypto/CommonCrypto.h>

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (Encryption)


- (NSData *)AES256EncryptWithKey:(NSData *)key   //加密
{
    //AES256加密，密钥应该是32位的
    
    //const void * keyPtr2 = [key bytes];
    
    //char (*keyPtr)[32] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    
    //所以在下边需要再加上一个块的大小
    
   return [self AESEncryptWithKey:key keySize:kCCKeySizeAES256];
    
}
- (NSData *)AES128EncryptWithKey:(NSData *)key{
    return [self AESEncryptWithKey:key keySize:kCCKeySizeAES128];
}

//加密
- (NSData *)AESEncryptWithKey:(NSData *)key keySize:(size_t) size{
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          
                                          kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/| kCCOptionECBMode,
                                          
                                          [key bytes], size,
                                          
                                          NULL,/* 初始化向量(可选) */
                                          
                                          [self bytes], dataLength,/*输入*/
                                          
                                          buffer, bufferSize,/* 输出 */
                                          
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    }
    
    free(buffer);//释放buffer
    
    return nil;
};
//解密
- (NSData *)AESDecryptWithKey:(NSData *)key keySize:(size_t) size{
    //同理，解密中，密钥也是32位的
    
    const void * keyPtr2 = [key bytes];
    
    const char (*keyPtr)[size] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    
    //所以在下边需要再加上一个块的大小
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          
                                          kCCOptionPKCS7Padding/*这里就是刚才说到的PKCS7Padding填充了*/| kCCOptionECBMode,
                                          
                                          keyPtr, size,
                                          
                                          NULL,/* 初始化向量(可选) */
                                          
                                          [self bytes], dataLength,/* 输入 */
                                          
                                          buffer, bufferSize,/* 输出 */
                                          
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    
    free(buffer);
    
    return nil;
}


- (NSData *)AES256DecryptWithKey:(NSData *)key {
    return [self AESDecryptWithKey:key keySize:kCCKeySizeAES256];
}

- (NSData *)AES128DecryptWithKey:(NSData *)key{
    return [self AESDecryptWithKey:key keySize:kCCKeySizeAES128];
}




- (NSString *)newStringInBase64FromData            //追加64编码
{
    
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    
    unsigned char * working = (unsigned char *)[self bytes];
    
    int srcLen = [self length];
    
    for (int i=0; i<srcLen; i += 3) {
        
        for (int nib=0; nib<4; nib++) {
            
            int byt = (nib == 0)?0:nib-1;
            
            int ix = (nib+1)*2;
            
            if (i+byt >= srcLen) break;
            
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            
            if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
            
            [dest appendFormat:@"%c", base64[curr]];
            
        }
        
    }
    
    return dest;
    
}

+ (NSString*)base64encode:(NSString*)str
{
    
    if ([str length] == 0)
        
        return @"";
    
    const char *source = [str UTF8String];
    
    int strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    
    if (characters == NULL)
        
        return nil;
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    
    while (i < strlength) {
        
        char buffer[3] = {0,0,0};
        
        short bufferLength = 0;
        
        while (bufferLength < 3 && i < strlength)
            
            buffer[bufferLength++] = source[i++];
        
        characters[length++] = base64[(buffer[0] & 0xFC) >> 2];
        
        characters[length++] = base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        
        if (bufferLength > 1)
            
            characters[length++] = base64[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        
        else characters[length++] = '=';
        
        if (bufferLength > 2)
            
            characters[length++] = base64[buffer[2] & 0x3F];
        
        else characters[length++] = '=';
        
    }
    
    NSString *g = [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
    return g;
    
}

+(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

+(NSString*)byteToString:(NSData*)data
{
    Byte *plainTextByte = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",plainTextByte[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
@end