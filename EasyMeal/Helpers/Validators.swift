//
//  Validators.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation

struct Validators {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidCPF(_ cpf: String) -> Bool {
        let numbers = cpf.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard numbers.count == 11 else { return false }
        
        let digitSet = Set(numbers)
        guard digitSet.count != 1 else { return false }
        
        let i1 = numbers.index(numbers.startIndex, offsetBy: 9)
        let i2 = numbers.index(numbers.startIndex, offsetBy: 10)
        let i3 = numbers.index(numbers.startIndex, offsetBy: 11)
        let d1 = Int(numbers[i1..<i2])!
        let d2 = Int(numbers[i2..<i3])!
        
        var temp1 = 0, temp2 = 0
        
        for i in 0...8 {
            let start = numbers.index(numbers.startIndex, offsetBy: i)
            let end = numbers.index(numbers.startIndex, offsetBy: i+1)
            let char = Int(numbers[start..<end])!
            
            temp1 += char * (10 - i)
            temp2 += char * (11 - i)
        }
        
        temp1 %= 11
        temp1 = temp1 < 2 ? 0 : 11 - temp1
        
        temp2 += temp1 * 2
        temp2 %= 11
        temp2 = temp2 < 2 ? 0 : 11 - temp2
        
        return temp1 == d1 && temp2 == d2
    }
    
    static func isValidCNPJ(_ cnpj: String) -> Bool {
        let numbers = cnpj.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard numbers.count == 14 else { return false }
        
        let digitSet = Set(numbers)
        guard digitSet.count != 1 else { return false }
        
        let multipliers1 = [5,4,3,2,9,8,7,6,5,4,3,2]
        let multipliers2 = [6,5,4,3,2,9,8,7,6,5,4,3,2]
        
        let i1 = numbers.index(numbers.startIndex, offsetBy: 12)
        let i2 = numbers.index(numbers.startIndex, offsetBy: 13)
        let i3 = numbers.index(numbers.startIndex, offsetBy: 14)
        let d1 = Int(numbers[i1..<i2])!
        let d2 = Int(numbers[i2..<i3])!
        
        var sum = 0
        for i in 0..<12 {
            let start = numbers.index(numbers.startIndex, offsetBy: i)
            let end = numbers.index(numbers.startIndex, offsetBy: i+1)
            let char = Int(numbers[start..<end])!
            sum += char * multipliers1[i]
        }
        
        var remainder = sum % 11
        let calculatedD1 = remainder < 2 ? 0 : 11 - remainder
        
        sum = 0
        for i in 0..<13 {
            let start = numbers.index(numbers.startIndex, offsetBy: i)
            let end = numbers.index(numbers.startIndex, offsetBy: i+1)
            let char = Int(numbers[start..<end])!
            sum += char * multipliers2[i]
        }
        
        remainder = sum % 11
        let calculatedD2 = remainder < 2 ? 0 : 11 - remainder
        
        return calculatedD1 == d1 && calculatedD2 == d2
    }
    
    static func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,11}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        let numbers = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return phonePred.evaluate(with: numbers)
    }
    
    static func formatCPF(_ cpf: String) -> String {
        let numbers = cpf.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if numbers.count <= 3 {
            return numbers
        } else if numbers.count <= 6 {
            return "\(numbers.prefix(3)).\(numbers.suffix(numbers.count - 3))"
        } else if numbers.count <= 9 {
            let part1 = numbers.prefix(3)
            let part2 = numbers.dropFirst(3).prefix(3)
            let part3 = numbers.dropFirst(6)
            return "\(part1).\(part2).\(part3)"
        } else {
            let part1 = numbers.prefix(3)
            let part2 = numbers.dropFirst(3).prefix(3)
            let part3 = numbers.dropFirst(6).prefix(3)
            let part4 = numbers.dropFirst(9).prefix(2)
            return "\(part1).\(part2).\(part3)-\(part4)"
        }
    }
    
    static func formatCNPJ(_ cnpj: String) -> String {
        let numbers = cnpj.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if numbers.count <= 2 {
            return numbers
        } else if numbers.count <= 5 {
            return "\(numbers.prefix(2)).\(numbers.suffix(numbers.count - 2))"
        } else if numbers.count <= 8 {
            return "\(numbers.prefix(2)).\(numbers.dropFirst(2).prefix(3)).\(numbers.dropFirst(5))"
        } else if numbers.count <= 12 {
            let part1 = numbers.prefix(2)
            let part2 = numbers.dropFirst(2).prefix(3)
            let part3 = numbers.dropFirst(5).prefix(3)
            let part4 = numbers.dropFirst(8)
            return "\(part1).\(part2).\(part3)/\(part4)"
        } else {
            let part1 = numbers.prefix(2)
            let part2 = numbers.dropFirst(2).prefix(3)
            let part3 = numbers.dropFirst(5).prefix(3)
            let part4 = numbers.dropFirst(8).prefix(4)
            let part5 = numbers.dropFirst(12).prefix(2)
            return "\(part1).\(part2).\(part3)/\(part4)-\(part5)"
        }
    }
}