//
//  NSq+Conversion.swift
//  Pods
//
//  Created by Kevin Tallevi on 7/7/16.
//
//

import Foundation

extension NSData {
    
    /**
     * @brief Method to convert a Data object to a hex String object
     * @return String object in hexadecimal format.
     */
    public func toHexString() -> String {
        let string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = 0
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02X", byte)
        }
        
        return string as String
    }
    
    public func dataRange(_ From: Int, Length: Int) -> NSData {
        let chunk = self.subdata(with: NSMakeRange(From, Length))
        
        return chunk as NSData
    }
    
    public func swapUInt16Data() -> NSData {
        
        // Copy data into UInt16 array:
        let count = self.length / MemoryLayout<UInt16>.size
        var array = [UInt16](repeating: 0, count: count)
        self.getBytes(&array, length: count * MemoryLayout<UInt16>.size)
        
        // Swap each integer:
        for i in 0 ..< count {
            array[i] = array[i].byteSwapped // *** (see below)
        }
        
        // Create NSData from array:
        return NSData(bytes: &array, length: count * MemoryLayout<UInt16>.size)
    }
    
    public func readInteger<T : Integer>(_ start : Int) -> T {
        var d : T = 0
        (self as NSData).getBytes(&d, range: NSRange(location: start, length: MemoryLayout<T>.size))
        
        return d
    }
    
    public func shortFloatToFloat() -> Float {
        let number8 : UInt8 = self.readInteger(0);
        let number : Int = Int(number8)
        
        // remove the mantissa portion of the number using bit shifting
        var exponent: Int = number >> 12
        
        if (exponent >= 8) {
            // exponent is signed and should be negative 8 = -8, 9 = -7, ... 15 = -1. Range is 7 to -8
            exponent = -((0x000F + 1) - exponent);
        }
        
        // remove exponent portion of the number using bit mask
        var mantissa:Int = number & 4095
        
        if (mantissa >= 2048) {
            //mantissa is signed and should be negative 2048 = -2048, 2049 = -2047, ... 4095 = -1. Range is 2047 to -2048
            mantissa = -((0x0FFF + 1) - mantissa);
        }
        
        let floatMantissa = Float(mantissa)
        
        return floatMantissa * Float(pow(10, Float(exponent)/1))
    }
    
    func lowNibbleAtPosition() ->Int {
        let number : UInt8 = self.readInteger(0);
        let lowNibble = number & 0xF
        
        return Int(lowNibble)
    }
    
    func highNibbleAtPosition() ->Int {
        let number : UInt8 = self.readInteger(0);
        let highNibble = number >> 4
        
        return Int(highNibble)
    }
}