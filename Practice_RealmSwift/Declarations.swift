//
//  Declarations.swift
//  Practice_RealmSwift
//
//  Created by pook on 6/15/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RealmSwift

// Definitions at the outermost scope... (Reason: https://stackoverflow.com/questions/36561749/how-do-i-move-a-realm-object-to-a-global-scope)
// 정의된 Thread에서만 사용할 수 있음. 여기서는 Main Thread
class Dog: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}

class Person: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var picture: Data? = nil
    @objc dynamic var planet: String = ""
    @objc dynamic var isFirst: Bool = false
    let dogs: List<Dog> = List<Dog>()
}

class Dog_1: Object {
    @objc dynamic var name = ""
    @objc dynamic var owner: Person_1? // Properties can be optional
}

class Person_1: Object {
    @objc dynamic var name = ""
    @objc dynamic var birthdate = Date(timeIntervalSince1970: 1)
    let dogs = List<Dog_1>()
}

class Person_3: Object {
    @objc dynamic var name: String? = nil
    let age = RealmOptional<Int>() // default: nil
}

class Person_4: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Book: Object {
    @objc dynamic var price = 0
    @objc dynamic var title = ""
    @objc dynamic var id = 0
    
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Person_5: Object {
    @objc dynamic var tmpID = 0
    var name: String {
        return "\(firstName) \(lastName)"
    }
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    
    override static func ignoredProperties() -> [String] {
        return ["tmpID"]
    }
}

class Car: Object {
    dynamic var make = ""
    @objc var name = ""
    let owner = List<Person_6>()
}

class Person_6: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    let dad = LinkingObjects(fromType: Person_6.self, property: "children")
    let children = List<Person_6>()
    let car = LinkingObjects(fromType: Car.self, property: "owner")
}

class Animal: Object {
    @objc dynamic var age = 0
    @objc dynamic var name = ""
}

class Duck: Object {
    @objc dynamic var animal: Animal? = nil
    @objc dynamic var name = ""
}

class Frog: Object {
    @objc dynamic var animal: Animal? = nil
    @objc dynamic var dateProp = Date()
}

class Car_1: Object {
    @objc dynamic var name: String = ""
}

class Dog_2: Object {
    @objc dynamic var color: String = ""
    @objc dynamic var name: String = ""
}

class Person_7: Object {
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var fullName = ""
    @objc dynamic var age = 0
}

class StepCounter: Object {
    @objc dynamic var steps = 0
}

class City: Object {
    @objc dynamic var city = ""
    @objc dynamic var cityId = 0
    
    override static func primaryKey() -> String? {
        return "cityId"
    }
}
