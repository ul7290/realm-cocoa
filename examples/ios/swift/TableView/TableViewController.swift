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

import UIKit
import RealmSwift

// Helpers

func randomString() -> String {
    return "Title \(arc4random())"
}

func randomDate() -> NSDate {
    return NSDate(timeIntervalSince1970: NSTimeInterval(arc4random()))
}

// Model

class DemoObject: Object {
    dynamic var title = ""
    dynamic var date = NSDate()
}

class Cell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}

class TableViewController: UITableViewController {

    var array = List<DemoObject>()
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // Set realm notification block
        notificationToken = defaultRealm().addNotificationBlock { _, _ in
            self.reloadData()
        }

        reloadData()
    }

    // UI

    func setupUI() {
        tableView.registerClass(Cell.self, forCellReuseIdentifier: "cell")

        self.title = "SwiftExample"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "BG Add", style: .Plain, target: self, action: "backgroundAdd")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add")
    }

    // Table view data source

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return Int(array.count)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as Cell

        let object = array[UInt(indexPath.row)]!
        cell.textLabel?.text = object.title
        cell.detailTextLabel?.text = object.date.description

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let realm = defaultRealm()
            realm.write {
                realm.delete(self.array[UInt(indexPath.row)]!)
            }
        }
    }

    // Actions

    func reloadData() {
        array = objects(DemoObject).sorted("date")
        tableView.reloadData()
    }

    func backgroundAdd() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        // Import many items in a background thread
        dispatch_async(queue) {
            // Get new realm and table since we are in a new thread
            defaultRealm().write {
                for index in 0..<5 {
                    // Add row via dictionary. Order is ignored.
                    DemoObject.createInDefaultRealmWithObject(["title": randomString(), "date": randomDate()])
                }
            }
        }
    }

    func add() {
        let realm = defaultRealm()
        realm.beginWrite()
        DemoObject.createInDefaultRealmWithObject([randomString(), randomDate()])
        realm.commitWrite()
    }
}
