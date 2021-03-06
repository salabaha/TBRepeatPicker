//
//  TBRPInternationalControl.swift
//  TBRepeatPicker
//
//  Created by hongxin on 15/9/30.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import Foundation

public class TBRPInternationalControl: NSObject {
    var language: TBRPLanguage = .english
    
    public convenience init(language: TBRPLanguage!) {
        self.init()
        
        self.language = language
    }

    private lazy var bundle: Bundle = {
        return Bundle(for: type(of: self)).url(forResource: "TBRepeatPicker", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) ?? Bundle.main
    }()
    
    fileprivate func localizedForKey(_ key: String!) -> String? {

        let path = self.bundle.path(forResource: TBRPInternationalControl.languageKey(language), ofType: "lproj")
        if let _ = path {
            let bundle = Bundle(path: path!)
            return bundle!.localizedString(forKey: key, value: nil, table: "TBRPLocalizable")
        } else {
            return nil
        }
    }
    
    public func localized(_ key: String!, comment: String!) -> String {
        if let localizedString = localizedForKey(key) as String? {
            if localizedString == key {
                return comment
            }
            return localizedString
        }
        return comment
    }
    
    public class func languageKey(_ language: TBRPLanguage) -> String {
        let languageKeys = ["en", "de", "zh-Hans", "zh-Hant", "ko", "ja"]
        
        return languageKeys[language.rawValue]
    }
}
