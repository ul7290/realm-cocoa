////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm

// Realm introspection depends on models to directly subclass RLMObject
// so we typealias it to remove the 'RLM' prefix
public class Object : RLMObject {
    // Get the names of all properties in the object which are of type List<>
    public class func getGenericListPropertyNames(obj: AnyObject) -> NSArray {
        let reflection = reflect(obj)

        var properties = [String]()

        // Skip the first property (super):
        // super is an implicit property on Swift objects
        for i in 1..<reflection.count {
            let mirror = reflection[i].1
            if mirror.valueType is RLMListBase.Type {
                properties.append(reflection[i].0)
            }
        }

        return properties
    }

    // The property initializers don't get called without overriding this from Swift
    public override init(realm: RLMRealm, schema: RLMObjectSchema, defaultValues: Bool) {
        super.init(realm: realm, schema: schema, defaultValues: defaultValues)
    }

    public override init(object: AnyObject) {
        super.init(object: object)
    }

    public override init() {
        super.init()
    }
}

// These types don't change when wrapping in Swift
// so we just typealias them to remove the 'RLM' prefix
public typealias PropertyType = RLMPropertyType
public typealias PropertyAttributes = RLMPropertyAttributes
public typealias NotificationToken = RLMNotificationToken
public typealias ObjectMigrationBlock = RLMObjectMigrationBlock
