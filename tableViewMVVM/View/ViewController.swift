//
//  ViewController.swift
//  tableViewMVVM
//
//  Created by Macbook on 07/02/2018.
//  Copyright © 2018 HE. All rights reserved.
//

import UIKit

///////!!!!!!! we add :class to limit that only class can implement protocol; struct, extension no
protocol TodoView: class {
    func insertTodoItem() -> ()
}

class ViewController: UIViewController {

    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var textFieldItem: UITextField!
    let identifier = "todoItemCellIdentifier"
    var viewModel: TodoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        let nib = UINib (nibName: "TodoItemTableViewCell", bundle: nil)
        tableViewItems.register(nib, forCellReuseIdentifier: identifier)
        
        // on remplie viewModel
        viewModel = TodoViewModel(view: self)
    }

    @IBAction func onAddItem(_ sender: UIButton) {
         /* with guard we can access to variable out the boucle, sinon question de style % if
               guard condition else {
               statements
               }
         */
        guard let newTodoValue = textFieldItem.text, !newTodoValue.isEmpty else{
            print("No value entred")
            return
        }
        viewModel?.onAddTodoItem(newValue: newTodoValue)
    }

}

/// we use use extension to do propre code
/// ---> You can keep your code organized by creating an extension for each protocol the type conforms to.
/// UITableViewDataSource : numberOfRowsInSection,
extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.items.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as?TodoItemTableViewCell
        
        let itemViewModel = viewModel?.items[indexPath.row]
        cell?.configure(withViewModel: itemViewModel!)
        
        return cell!
    }
}

//UITableViewDelegate: didSelectRowAt
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}


extension ViewController: TodoView {
    
    func insertTodoItem(){
        
        guard let items = viewModel?.items else {
            print ("items object is empty")
            return
        }
        
        self.tableViewItems.beginUpdates()
        self.tableViewItems.insertRows(at: [IndexPath(row: items.count-1, section:0)], with: .automatic)
        self.tableViewItems.endUpdates()
    }
}

