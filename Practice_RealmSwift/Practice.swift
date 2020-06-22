//
//  Practice.swift
//  Practice_RealmSwift
//
//  Created by pook on 6/9/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import Foundation
import RealmSwift

let Practice: [(name: String, foo: () -> ())] = [
    ("Test", {
        let car: Car_1 = Car_1()
        car.name = "Hyundai"
        
        let config = Realm.Configuration(objectTypes: [Car_1.self])
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            realm.add(car)
        }
        
        // Check
        
        let changed_car: Car_1 = realm.objects(Car_1.self)[0]
        
        if !(car === changed_car) {
            print("Different references")
        }
        
        try! realm.write() {
            car.name = "TOYOTA"
        }
        
        print(changed_car.name) // TOYOTA
    }),
    
    ("Getting started", {
        let myDog = Dog()
        myDog.name = "Rex"
        myDog.age = 1
        print("name of dog: \(myDog.name)")
        
        let realm = try! Realm()
        
        let puppies = realm.objects(Dog.self).filter("age < 2")
        print(puppies.count) // 0 because no dogs have been added to the Realm yet...
        
        try! realm.write {
            realm.add(myDog)
        }
        
        print(puppies.count) // now 1
        
        DispatchQueue(label: "background").async {
            autoreleasepool {
                let realm = try! Realm()
                let theDog = realm.objects(Dog.self).filter("age == 1").first
                try! realm.write {
                    theDog!.age = 3
                }
            }
        }
    }),
    
    /*
     iOS 8 이후로 기기가 잠기면 NSFileProtection이 실행되어서 앱 내부 파일들이 자동으로 암호화가 됨
     그래서 잠겨진 상태에서 Realm을 실행하면 open() failed: Operation not permitted이라는 Error가 throw됨
     이를 방지하기 위해
     
     1. 잠금 화면에서도 접근을 허용하는 NSFileProtectionCompleteUntilFirstUserAuthentication을 쓰거나
     2. 암호화를 끄거나
     3. 암호화는 꺼도, Realm에서 제공하는 암호화 방식을 사용
     
     아래는 2번 방법
     
     Realm 문서의 코드가 잘못되어서, 아래 링크의 방법을 사용해야함
     https://pspdfkit.com/blog/2017/how-to-use-ios-data-protection/
     */
    ("Using Realm with background app refresh", {
        let realm = try! Realm()
        
        // Realm의 URL directory를 String
        let folderPath: String = realm.configuration.fileURL!.deletingLastPathComponent().path
        try! FileManager.default.setAttributes([.protectionKey: FileProtectionType.none],
                                               ofItemAtPath: folderPath)
    }),
    
    ("Configuring a Local Realm (Default)", {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("Custom.realm")
        Realm.Configuration.defaultConfiguration = config
    }),
    
    ("Configuring a Local Realm (Each)", {
        let config = Realm.Configuration(
            fileURL: Bundle.main.url(forResource: "MyBundledData", withExtension: "realm"),
            readOnly: true
        )
        
        let realm = try! Realm(configuration: config)
        
        let results = realm.objects(Dog.self).filter("age > 5")
    }),
    
    /*
     inMemoryIdentifier, fileURL 둘중 하나는 nil
     만약 inMemoryIdentifier로 정의된 Realm이 deinit될 경우 (특히 ARC), 메모리에 있는 내용들이 사라짐 (on-disk는 상관없음)
     그래서 웬만하면 strong으로 정의하는게 좋음
     */
    ("Configuring In-memory Realm", {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
    }),
    
    
    ("Error Handling", {
        do {
            let ream = try Realm()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }),
    
    ("Building a Realm", {
        /*
         앱에 초기 데이터가 있는 Realm을 제공하고 싶은 경우
         1. Realm 파일 작성
         2. 크기 최적화 (압축 - shouldCompactOnLaunch)
         3. Xcode 번들에 복사
         4. 수정을 원치 않을 경우 readOnly = true
         5. 수정할 경우 다른 곳에 복사
         */
        
    }),
    
    /*
     objectTypes가 비어 있으면 이 Project에 정의된 모든 Object들이 들어옴
     정의해주면 그것만 들어옴
     */
    ("Class subsets", {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("Custom.realm")
        config.objectTypes = [Dog.self]
        
        let realm = try! Realm(configuration: config)
    }),
    
    /*
     The compaction operation works by reading the entire contents of the Realm file, rewriting it to a new file at a different location, then replacing the original file. Depending on the amount of data in a file, this may be an expensive operation.
     */
    ("Compacting Realms", {
        let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file
            
            // Compact if the file is voer 100MB in size and less then 50% 'used'
            let oneHundredMB = 100 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
    }),
    
    ("Deleting Realms files", {
        autoreleasepool {
            // all Realm usage here
        }
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs: [URL] = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        realmURLs.forEach {
            do {
                try FileManager.default.removeItem(at: $0)
            } catch {
                print(error.localizedDescription)
            }
        }
    }),
    
    ("Supported property types", {
        // Supported: Bool Int Int8 Int16 Int32 Int64 Double Float String Date Data
        // CGFloat properties are discouraged, as the type is not platform indepedent.
        // String, Data and Data properties can be optional. Object properties must be optional. Storing optional numbers is done using RealmOptional.
    }),
    
    ("Required properties", {
        let config = Realm.Configuration(objectTypes: [Person_3.self])
        
        let realm = try! Realm(configuration: config)
        try! realm.write() {
            var person = realm.create(Person_3.self, value: ["Jane", 27])
            person.age.value = 28
        }
    }),
    
    // https://academy.realm.io/posts/realm-primary-keys-tutorial/
    ("Primary keys", {
        let config = Realm.Configuration(objectTypes: [Person_4.self])
        
        let realm = try! Realm(configuration: config)
        try! realm.write() {
            var person = realm.create(Person_4.self, value: [30, "John"])
        }
        
        let thatPerson = realm.object(ofType: Person_4.self, forPrimaryKey: 30)
        print(thatPerson?.name)
    }),
    
    // https://academy.realm.io/posts/nspredicate-cheatsheet/
    ("Indexing Properties", {
        let config = Realm.Configuration(objectTypes: [Book.self])
        
        let realm = try! Realm(configuration: config)
        try! realm.write() {
            var book = realm.create(Book.self, value: [10, "RealmSwift"])
        }
        
        var thatBook = realm.objects(Book.self).filter("title in {'RealmSwift'}")
        print(type(of: thatBook))
        print(thatBook[0].price)
    }),
    
    ("Ignoring properties", {
        let config = Realm.Configuration(objectTypes: [Person_5.self])
        
        let realm = try! Realm(configuration: config)
        try! realm.write() {
            var book = realm.create(Person_5.self)
        }
    }),
    
    ("Property attributes", {
        /*
         Realm model properties must have the @objc dynamic var attribute to become accessors for the underlying database data. Note that if the class is declared as @objcMembers (Swift 4 or later), the individual properties can just be declared as dynamic var.
         
         There are three exceptions to this: LinkingObjects, List and RealmOptional. Those properties cannot be declared as dynamic because generic properties cannot be represented in the Objective‑C runtime, which is used for dynamic dispatch of dynamic properties. These properties should always be declared with let.
         
         reference가 바뀌질 바라지 않아서 let으로 해야함. 해당 reference의 value를 바꾸면 되니 상관없음
         */
    }),
    
    ("LinkingObjects", {
        var config = Realm.Configuration(objectTypes: [Car.self, Person_6.self])
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("Link").appendingPathExtension("realm")
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            var dad = realm.create(Person_6.self, value: ["Tony", 38])
            var child = realm.create(Person_6.self, value: ["John", 3])
            dad.children.append(child)
            child.age = 4
            print(child.dad[0].name)
        }
    }),
    
    ("Auto-updating objects", {
        let myDog = Dog()
        myDog.name = "Fido"
        myDog.age = 1
        
        let config = Realm.Configuration(objectTypes: [Dog.self])
        let realm = try! Realm()
        
        try! realm.write() {
            realm.add(myDog)
        }
        
        let myPuppy = realm.objects(Dog.self).filter("age == 1").first!
        
        try! realm.write() {
            myPuppy.age = 2
        }
        
        print("\(myDog.age) \(myPuppy.age)")
        
        if myDog === myPuppy {
            print("same reference") // Nothing
        }
    }),
    
    // View detail on documentation...
    ("Model inheritance", {
        // This is an alternative code cuz of Realm's limiation...
        let config = Realm.Configuration(objectTypes: [Duck.self, Animal.self])
        let realm = try! Realm(configuration: config)
        
        let duck = Duck(value: [
            "animal": ["age": 3],
            "name": "Gustav"]
        )
        
        try! realm.write() {
            realm.add(duck)
        }    }),
    
    /*
     1. Results: 쿼리를 통해 반환된 객체를 나타내는 클래스
     2. List: 모델의 1 대 다 관계를 나타내는 클래스
     3. LinkingObjects: 모든 역관계를 나타내는 클래스
     
     4. RealmCollection: 모든 Realm 컬렉션이 따르는(conform) 공통 인터페이스를 정의하는 protocol
     5. AnyRealmCollection: 위 클래스들은 불변인데, 타입 제거를 해주는 클래스 (뭔 말인지 모르겠음)
     */
    ("Collections", {
        func operateOn<C: RealmCollection>(collection: C) {
            print("operating on collection containing \(collection.count) objects")
        }
        
        let dog = Dog_1()
        dog.name = "ABC"
        
        let person = Person_1()
        person.dogs.append(dog)
        
        operateOn(collection: person.dogs)
    }),
    
    ("Many-to-one", {
        let dog_1 = Dog_1()
        let dog_2 = Dog_1()
        let person = Person_1()
        
        person.dogs.append(objectsIn: [dog_1, dog_2])
    }),
    
    ("Many-to-many", {
        let config = Realm.Configuration(objectTypes: [Dog_1.self, Person_1.self])
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            realm.create(Dog_1.self, value: ["AA"])
            realm.create(Dog_1.self, value: ["BB"])
        }
        
        //        let ADog = realm.objects(Dog_1.self).filter("name == 'A'")[0]
        let ADog = realm.objects(Dog_1.self).filter("name contains 'A'")[0]
        let person = Person_1()
        person.dogs.append(ADog)
        print(ADog.name)
    }),
    
    ("Inverse relationships = LinkingObjects", {
        
    }),
    
    ("LinkingObjects (1)", {
        let config = Realm.Configuration(objectTypes: [Car.self, Person_6.self])
        let realm = try! Realm(configuration: config)
        
        let person = Person_6()
        let car = Car()
        
        car.name = "Hyundai"
        car.owner.append(person)
        
        try! realm.write() {
            realm.add(car)
            realm.add(person)
        }
        
        if car === person.car.last! {
            print("Same")
        }
        print("0")
        print(person.car.last!.name)
        print("1")
        print(car.name)
        
        try! realm.write() {
            car.name = "TOYOTA"
        }
        
        print("3")
        print(person.car.last!.name)
        print("4")
        print(car.name)
        
        try! realm.write() {
            person.car.last!.name = "HONDA"
        }
        
        print("5")
        print(person.car.last!.name)
        print("6")
        print(car.name)
    }),
    
    ("LinkingObjects (2)", {
        let config = Realm.Configuration(objectTypes: [Car.self, Person_6.self])
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            let car = realm.create(Car.self)
            let person = realm.create(Person_6.self)
            
            car.name = "Hyundai"
            print(car.name)
            car.owner.append(person)
        }
        
        let car = realm.objects(Car.self)[0]
        let person = realm.objects(Person_6.self)[0]
        
        if car === person.car.last! {
            print("Same") // Nothing
        }
        print("0")
        print(person.car.last!.name)
        print("1")
        print(car.name)
    }),
    
    ("Creating objects", {
        var animal_1: Animal = Animal()
        animal_1.age = 3
        animal_1.name = "Lion"
        
        var animal_2: Animal = Animal(value: ["age": 9, "name": "Lion"])
        
        var animal_3: Animal = Animal(value: [3])
        
        // Nested objects
        var duck = Duck(value: [animal_3, "Duuuuuck"])
        // if type is List<T>, you can replace it with []...
        // let aPerson = Person(value: ["Jane", 30, [aDog, anotherDog]])
    }),
    
    ("Key-value coding", {
        let realm = try! Realm()
        let persons = realm.objects(Person.self)
        try! realm.write {
            realm.create(Person.self)
            persons.first?.setValue(true, forKey: "isFirst")
            persons.setValue("Earch", forKey: "planet")
        }
    }),
    
    ("Objects with primary keys", {
        let realm = try! Realm()
        
        let cheeseBook = Book()
        cheeseBook.title = "Cheese recipes"
        cheeseBook.price = 900
        cheeseBook.id = 1
        
        try! realm.write {
            //            realm.add(cheeseBook)
            realm.add(cheeseBook, update: .modified) // also new objects can be added with .modified arugment.
            realm.create(Book.self, value: ["id": 3], update: .modified) // if id (primaryKey) is same, it cannot be created with no runtime error.
        }
        
        /*
         update:
         .all
         .modified
         */
    }),
    
    ("Deleting objects", {
        let realm = try! Realm()
        let cheeseBook = Book()
        
        try! realm.write() {
            realm.add(cheeseBook)
            realm.delete(cheeseBook)
            realm.deleteAll()
        }
    }),
    
    ("Queries (filter, NSPredicate)", {
        let realm = try! Realm()
        var tanDogs = realm.objects(Dog_2.self).filter("color = 'tan' AND name BEGINSWITH 'B'")
        
        let predicate: NSPredicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
        tanDogs = realm.objects(Dog_2.self).filter(predicate)
    }),
    
    ("Sorting", {
        let realm = try! Realm()
        let predicate: NSPredicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
        let sortedDogs = realm.objects(Dog_2.self).filter(predicate).sorted(byKeyPath: "name")
    }),
    
    ("Chaining queries", {
        let realm = try! Realm()
        let predicate: NSPredicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
        let sortedDogs = realm.objects(Dog_2.self)
            .filter(predicate)
            .sorted(byKeyPath: "name")
            .sorted(byKeyPath: "color", ascending: false)
    }),
    
    ("Auto-updating results (1)", {
        let realm = try! Realm()
        let puppies = realm.objects(Dog.self).filter("age < 2")
        print(puppies.count) // 0
        try! realm.write() {
            realm.create(Dog.self, value: ["name": "Fido", "age": 1])
        }
        print(puppies.count) // 1
    }),
    
    ("Auto-updating results (2)", {
        let realm = try! Realm()
        try! realm.write() {
            for dog in realm.objects(Dog.self) {
                dog.age = 3
            }
        }
    }),
    
    ("Limiting results (Subscript)", {
        let realm = try! Realm()
        let dogs = try! realm.objects(Dog.self)
        for i in 0..<5 {
            let dog = dogs[i]
            print(dog.age)
        }
    }),
    
    // To test Migrations...
    
    /*
     1. comment fullName property of Person_7 and the last lien of Step 2 (print)
     2. run Step 1 only
     3. uncomment all of them and Build again
     4. run Step 2, now you can show fullName, result of Migration!
     */
    
    // Tip: If you init Realm with default configuration, and if you change default config (static) after init, the initted Realm won't be changed.
    
    ("Migrations (Step 1)", {
        let config_1 = Realm.Configuration(objectTypes: [Person_7.self]) // default schemaVersion is 0
        let realm_1 = try! Realm(configuration: config_1)
        
        try! realm_1.write() {
            realm_1.create(Person_7.self, value: ["firstName": "Jinwoo", "lastName": "Kim", "age": 22])
        }
    }),
    
    ("Migrations (Step 2)", {
        let config_2 = Realm.Configuration(
            schemaVersion: 1,
            
            migrationBlock: { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: "Person_7") { oldObject, newObject in
                        let firstName = oldObject!["firstName"] as! String
                        let lastName = oldObject!["lastName"] as! String
                        newObject!["fullName"] = "\(firstName) \(lastName)"
                    }
                }
        },
            
            objectTypes: [Person_7.self]
        )
        let realm_2 = try! Realm(configuration: config_2)
        print(realm_2.objects(Person_7.self).first!.fullName)
    }),
    
    ("Renaming properties", {
        // This code won't work.
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.renameProperty(onType: "Person_7", from: "yearsSinchBirth", to: "age")
                }
        },
            objectTypes: [Person_7.self]
        )
    }),
    
    ("Realm notifications (Basic)", {
        let realm = try! Realm()
        let token = realm.observe { notification, realm in
            // Do something...
        }
        token.invalidate()
    }),
    
    // Start writing...
    // same
    // Gotcha!
    ("Realm notifications (In Action)", {
        let config = Realm.Configuration(objectTypes: [Dog_2.self])
        let realm_1 = try! Realm(configuration: config)
        
        let token = realm_1.observe { notification, realm_2 in
            if realm_1 == realm_2 {
                print("same") // same
            }
            print("Gotcha!")
        }
        
        try! realm_1.write() {
            print("Start writing...")
            realm_1.create(Dog_2.self)
        }
        
        token.invalidate()
    }),
    
    ("Without notifying", {
        let realm = try! Realm()
        let token = realm.observe { notification, realm in
            // ...
        }
        
        try! realm.write(withoutNotifying: [token]) {
            // ...
        }
        
        token.invalidate()
    }),
    
    // If you're in ViewController...
    
    /*
     class ViewController: UIViewController {
     var notificationToken: NotificationToken? = nil
     
     override func viewDidLoad() {
     super.viewDidload()
     
     // Declaration of notificationToken...
     }
     
     deinit { notificationToken?.invalidate() }
     }
     */
    ("Collection notifications (Results notifications)", {
        let config = Realm.Configuration(objectTypes: [Person_7.self])
        let realm = try! Realm()
        let result = realm.objects(Person_7.self).filter("age > 5")
        
        // if you need [weak self], write
        let notificaionToken = result.observe { [] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(let x):
                print("initial")
                () // x is Results<Dog_2>
            case .update(let all, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                // all: Results<Dog_2>, and the others are [Int]
                print("update")
                ()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        }
        
        try! realm.write() {
            let person = realm.create(Person_7.self, value: ["age": 9]) // initial
            person.age = 10 // update notification won't be woken
        }
        
        try! realm.write() {
            let person = realm.objects(Person_7.self).first!
            person.age = 90 // update
        }
        
        notificaionToken.invalidate()
    }),
    
    ("Object notifications", {
        let stepCounter = StepCounter()
        let config = Realm.Configuration(objectTypes: [StepCounter.self])
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            realm.add(stepCounter)
        }
        
        var token: NotificationToken?
        
        token = stepCounter.observe { change in
            switch change {
            case .change(_, let properties):
                for property in properties {
                    if property.name == "steps" {
                        print("Step!")
                    }
                    if property.name == "steps" && property.newValue as! Int > 1000 {
                        print("Congratulations, you've exceeded 1000 steps.")
                        token = nil
                    }
                }
            case .error(let error):
                print(error.localizedDescription) // if an error occurs, the block will never be called again.
            case .deleted:
                print("The object was deleted.")
            }
        }
        
        for step in 0..<1100 {
            try! realm.write() {
                stepCounter.steps = step
            }
        }
        
        /* ... then how about this code?
         try! realm.write() {
            for step in 0..<1100 {
                stepCounter.steps = step
            }
         }
         
         this code only sents one notification, because write() is called once. so the result is only
         
         Step!
         Congratulations, you've exceeded 1000 steps.
         */
    }),
    
    ("Encryption", {
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 64, bytes)
        }
        
        let config = Realm.Configuration(encryptionKey: key, objectTypes: [Car_1.self])
        let realm = try! Realm(configuration: config)
        
        try! realm.write() {
            realm.create(Car_1.self, value: ["name": "Hyundai"])
        }
    }),
    
    ("Passing instances across threads (Bad 1)", {
        let config = Realm.Configuration(objectTypes: [Dog.self])
        let realm = try! Realm(configuration: config)
        
        let dog = Dog(value: ["age": 3])
        try! realm.write {
            realm.add(dog)
        }
        
        //
        
        DispatchQueue(label: "backgrond").async {
            autoreleasepool {
                try! realm.write {
                    dog.age = 8
                }
            }
        }
    }),
    
    ("Passing instances across threads (Bad 2)", {
        let config = Realm.Configuration(objectTypes: [Dog.self])
        let realm = try! Realm(configuration: config)
        
        let dog = Dog(value: ["age": 3])
        try! realm.write {
            realm.add(dog)
        }
        
        //
        let dogRef = ThreadSafeReference(to: dog)
        
        try! realm.write {
            dog.age = 6
        }
        
        DispatchQueue(label: "backgrond").async {
            autoreleasepool {
                guard let dog = realm.resolve(dogRef) else {
                    return
                }
                
                try! realm.write {
                    dog.age = 8
                }
            }
        }
    }),
    
    ("Passing instances across threads (Good)", {
        let config = Realm.Configuration(objectTypes: [Dog.self])
        let realm = try! Realm(configuration: config)
        
        let dog = Dog(value: ["age": 3])
        try! realm.write {
            realm.add(dog)
        }
        
        //
        let dogRef = ThreadSafeReference(to: dog)
        
        try! realm.write {
            dog.age = 6
        }
        
        DispatchQueue(label: "backgrond").async {
            autoreleasepool {
                let realm = try! Realm(configuration: config)
                guard let dog = realm.resolve(dogRef) else {
                    return
                }
                
                try! realm.write {
                    dog.age = 8
                }
            }
        }
    }),
    
    ("Using a Realm across threads", {
        DispatchQueue(label: "background").async {
            autoreleasepool {
                let realm = try! Realm()
                
                for idx1 in 0..<1000 {
                    realm.beginWrite()
                    
                    for idx2 in 0..<1000 {
                        realm.create(Dog.self,
                                     value: ["name": "\(idx1)", "age": idx2])
                    }
                    
                    try! realm.commitWrite()
                }
            }
        }
    }),
    
    ("JSON", {
        let data: Data = "{\"name\": \"San Francisco\", \"cityId\": 123}".data(using: .utf8)!
        let realm = try! Realm()
        
        try! realm.write {
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            
            realm.create(City.self, value: json, update: .modified)
        }
    })
]
