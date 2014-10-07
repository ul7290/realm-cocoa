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

public class ListBase: RLMListBase, Printable {
    // Printable requires a description property defined in Swift (and not obj-c),
    // and it has to be defined as @objc override, which can't be done in a
    // generic class.
    @objc public override var description: String { return super.description }
    public var count: UInt { return _rlmArray.count }
}

public final class List<T: Object>: ListBase, SequenceType {
    // MARK: Properties

    public var realm: Realm { return Realm(rlmRealm: _rlmArray.realm) }

    // MARK: Initializers

    public init(_ rlmArray: RLMArray? = nil) {
        super.init(array: rlmArray ?? RLMArray(objectClassName: demangleClassName(NSStringFromClass(T))))
    }

    // MARK: Index Retrieval

    public func indexOf(object: T) -> UInt? {
        return _rlmArray.indexOfObject(object)
    }

    public func indexOf(predicate: NSPredicate) -> UInt? {
        return _rlmArray.indexOfObjectWithPredicate(predicate)
    }

    public func indexOf(predicateFormat: String, _ args: CVarArgType...) -> UInt? {
        return _rlmArray.indexOfObjectWhere(predicateFormat, args: getVaList(args))
    }

    // MARK: Object Retrieval

    public subscript(index: UInt) -> T {
        get {
            return _rlmArray[index] as T
        }
        set {
            return _rlmArray[index] = newValue
        }
    }

    public func first() -> T? {
        return _rlmArray.firstObject() as T?
    }

    public func last() -> T? {
        return _rlmArray.lastObject() as T?
    }

    // MARK: Subarray Retrieval

    public func filter(predicateFormat: String, _ args: CVarArgType...) -> List<T> {
        return List<T>(_rlmArray.objectsWhere(predicateFormat, args: getVaList(args)))
    }

    public func filter(predicate: NSPredicate) -> List<T> {
        return List<T>(_rlmArray.objectsWithPredicate(predicate))
    }

    // MARK: Sorting

    public func sorted(property: String, ascending: Bool = true) -> List<T> {
        return List<T>(_rlmArray.arraySortedByProperty(property, ascending: ascending))
    }

    // MARK: Aggregate Operations

    public func min<U: Sortable>(property: String) -> U {
        return _rlmArray.minOfProperty(property) as U
    }

    public func max<U: Sortable>(property: String) -> U {
        return _rlmArray.maxOfProperty(property) as U
    }

    public func sum(property: String) -> Double {
        return _rlmArray.sumOfProperty(property) as Double
    }

    public func average(property: String) -> Double {
        return _rlmArray.averageOfProperty(property) as Double
    }

    // MARK: Sequence Support

    public func generate() -> GeneratorOf<T> {
        var i: UInt = 0
        return GeneratorOf<T>() {
            if (i >= self._rlmArray.count) {
                return .None
            } else {
                return self._rlmArray[i++] as? T
            }
        }
    }

    // MARK: Mutating

    public func append(object: T) {
        _rlmArray.addObject(object)
    }

    public func append(objects: [T]) {
        _rlmArray.addObjectsFromArray(objects)
    }

    public func append(list: List<T>) {
        _rlmArray.addObjectsFromArray(list._rlmArray)
    }

    public func insert(object: T, atIndex index: UInt) {
        _rlmArray.insertObject(object, atIndex: index)
    }

    public func remove(index: UInt) {
        _rlmArray.removeObjectAtIndex(index)
    }

    public func remove(object: T) {
        if let index = indexOf(object) {
            remove(index)
        }
    }

    public func removeLast() {
        _rlmArray.removeLastObject()
    }

    public func removeAll() {
        _rlmArray.removeAllObjects()
    }
    
    public func replace(index: UInt, object: T) {
        _rlmArray.replaceObjectAtIndex(index, withObject: object)
    }
}
