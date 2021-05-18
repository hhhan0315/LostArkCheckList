//
//  ViewControllerExtension.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/18.
//

import UIKit

extension UIViewController {
    func callCharacterArray() -> [String] {
        guard let characterArray = UserDefaults.standard.stringArray(forKey: "characterArray") else {
            return []
        }
        return characterArray
    }
    
    func saveCharacterArray(characterArray: [String]) {
        UserDefaults.standard.setValue(characterArray, forKey: "characterArray")
        UserDefaults.standard.synchronize()
    }
    
    func callCharacterDict(characterTitle: String) -> [String:[Todo]]? {
        var characterDict: [String:[Todo]]? = [:]
        if let characterData = UserDefaults.standard.value(forKey: characterTitle) as? Data {
            characterDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: characterData)
        }
        return characterDict
    }
    
    func saveCharacterDict(characterDict: [String:[Todo]]?, characterTitle: String) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(characterDict), forKey: characterTitle)
        UserDefaults.standard.synchronize()
    }
    
    func callTodoDict() -> [String:[Todo]]? {
        var todoDict: [String:[Todo]]? = [:]
        if let todoData = UserDefaults.standard.value(forKey:"todoDict") as? Data {
            todoDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: todoData)
        }
        return todoDict
    }
    
    func saveTodoDict(todoDict: [String:[Todo]]?) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(todoDict), forKey: "todoDict")
        UserDefaults.standard.synchronize()
    }
}
