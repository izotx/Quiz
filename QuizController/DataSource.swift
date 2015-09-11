//
//  DataSource.swift
//  QuizController
//
//  Created by Janusz Chudzynski on 8/31/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit

class DataSource: NSObject, UITableViewDataSource {
    var items: [AnyObject]
    var configureCell:((cell:UITableViewCell, item: AnyObject,indexPath:NSIndexPath)->Void)
    var cellIdentifier:String
   
    init(items:[AnyObject], identifier:String, cellhandler: (cell:UITableViewCell, item: AnyObject, indexPath:NSIndexPath)->Void){

        self.items = items
        self.configureCell = cellhandler
        self.cellIdentifier = identifier
        super.init()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //UITableViewCell
        var cell =  tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! UITableViewCell
        let item: AnyObject = items[indexPath.row]
        self.configureCell(cell: cell, item: item, indexPath:indexPath)
        
        
        return cell
    }
    
 

}
