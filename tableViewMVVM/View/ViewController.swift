//
//  ViewController.swift
//  tableViewMVVM
//  Created by Macbook on 07/02/2018.
//  Copyright © 2018 HE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


///////!!!!!!! we add :class to limit that only class can implement protocol; struct, extension no
/////ep5 deleted
/*protocol TodoView: class {
    ///ep5 deleted
    //func insertTodoItem() -> ()
    func removeTodoItem(at index: Int) -> ()
    func updateTodoItem(at index: Int) -> ()
    func reloadItems() -> ()
}*/

class ViewController: UIViewController {

    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var textFieldItem: UITextField!
    let identifier = "todoItemCellIdentifier"
    var viewModel: TodoViewModel?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        let nib = UINib (nibName: "TodoItemTableViewCell", bundle: nil)
        tableViewItems.register(nib, forCellReuseIdentifier: identifier)
        
        /// on remplie viewModel
        /// when inialize TodoViewModel, we create the items with the parent (TodoView:insertTodoItem,removeTodoItem)
        /// in each item, we initialize: id, textValue, parent, menuItems (DoneMenuItemViewModel,RemoveMenuItemViewModel)
        /// the parent: onAddTodoItem, onTodoDelete, onTodoDone : les actions when clic to add item button or remove or done
        viewModel = TodoViewModel()
        
        ////ep5
        viewModel?.items.asObservable().bind(to: tableViewItems.rx.items(cellIdentifier: identifier, cellType: TodoItemTableViewCell.self)) { index,item, cell in
            cell.configure(withViewModel: item)
            }.disposed(by: disposeBag)
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
        ////// added to remplace passing value in method
        viewModel?.newTodoItem = newTodoValue
        
        //// global because il va faire du traitement dans le model, ajouter...
        DispatchQueue.global(qos: .background).async {
            /// opt soit async ou sync
            /// we can use DispatchQueue.global(qos: .background).async  or  DispatchQueue.main.sync
            DispatchQueue.main.sync {
                 self.viewModel?.onAddTodoItem()
            }
        }
    }    
}

/// we use use extension to do propre code
/// ---> You can keep your code organized by creating an extension for each protocol the type conforms to.
/// UITableViewDataSource : numberOfRowsInSection,

/// ep5 (rx) delete extension ViewController: UITableViewDataSource and delete datasource in storyboard
/*extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = viewModel?.items.value else{
            return 0
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as?TodoItemTableViewCell
        
        let itemViewModel = viewModel?.items.value[indexPath.row]
        cell?.configure(withViewModel: itemViewModel!)
        
        return cell!
    }
}*/

//UITableViewDelegate: didSelectRowAt
extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewModel = viewModel?.items.value[indexPath.row]
        (itemViewModel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let itemViewModel = viewModel?.items.value[indexPath.row]
        
        print("")
        
        ///// added to swipe action /////////////
        var menuActions: [UIContextualAction] = []
        _ = itemViewModel?.menuItems?.map({ menuItem in
            
            ///// this block moved in the menuItems?.map to   swipe action  ///////////
            let menuAction = UIContextualAction(style: .normal, title: menuItem.title) { (action, sourceView, success: (Bool) -> (Void)) in
                
                if let delegate = menuItem as? TodoMenuItemViewDelegate {
                    /// global because it has trait in model, remove....
                    DispatchQueue.global(qos: .background).async {
                        //self.viewModel?.onDeleteItem(todoId: (itemViewModel?.id)!)
                        delegate.onMenuItemSelected()
                    }
                }
                
                success(true)
            }
            
             menuAction.backgroundColor = menuItem.backColor!.hexColor
            /////////////////////////////////////////////////////////////////////////
            
            menuActions.append(menuAction)
            
        })
        ///////////////////////////////////////
       
        return UISwipeActionsConfiguration(actions: menuActions)
    }

}

////ep5 deleted
/*extension ViewController: TodoView {
    
    ////ep5 deleted
    /*func insertTodoItem(){

        print("insertTodoItem")
        
        guard let items = viewModel?.items else {
            print ("items object is empty")
            return
        }
        
        //////main because it is for the display result
        DispatchQueue.main.async(execute: { () -> Void in
            ////// added to remplace passing value in method
            self.textFieldItem.text = self.viewModel?.newTodoItem!
            
            self.tableViewItems.beginUpdates()
            self.tableViewItems.insertRows(at: [IndexPath(row: items.value.count-1, section:0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }*/
    
    func removeTodoItem(at index: Int){
        
        //UITableView.beginUpdates() and endUpdates() and deleteRows must be used from main thread only
        //// UITableView.beginUpdates() and endUpdates() used to update interface
        DispatchQueue.main.async(execute: {() -> Void in
            self.tableViewItems.beginUpdates()
            self.tableViewItems.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }
    
    ///added ep4, then replaced with reloadItems
    func updateTodoItem(at index: Int){
         DispatchQueue.main.async(execute: {() -> Void in
           self.tableViewItems.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
         })
    }
    
    func reloadItems(){
        DispatchQueue.main.async(execute: {() -> Void in
            self.tableViewItems.reloadData()
        })
    }
}*/

