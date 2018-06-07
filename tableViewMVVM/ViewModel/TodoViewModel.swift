//
//  TodoViewModel.swift
//  tableViewMVVM
//
//  Created by Macbook on 07/02/2018.
//  Copyright © 2018 HE. All rights reserved.
//

import RxSwift

////////// added to swipe action ////////////////////
protocol TodoMenuItemViewPresentable {
    var title : String? {get set}
    var backColor : String? {get}
}

protocol TodoMenuItemViewDelegate: class {
    ///this method, it defined in class TodoMenuItemViewModel, and in the class it overried in RemoveMenuItemViewModel and DoneMenuItemViewModel
    func onMenuItemSelected() -> ()
}

// class implement 2 protocols
class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    var title : String?
    var backColor : String?
    ////added to action swipe
    weak var parent: TodoItemViewDelegate?
    
    init(parentViewModel: TodoItemViewDelegate) {
        ///parentViewModel : id, textValue, isDone(bool), menuItems, parent(todoviewdelegate): protocol contain the 3 methods: (onAddTodoItem, onTodoDelete, onTodoDone)
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected(){
        
    }
}

// class extend class
class RemoveMenuItemViewModel: TodoMenuItemViewModel{
    override func onMenuItemSelected(){
        print (" remove menu item");
        parent?.onRemoveSelected()
    }
}

// class extend class
class DoneMenuItemViewModel: TodoMenuItemViewModel{
    override func onMenuItemSelected(){
         print (" done menu item");
         parent?.onDoneSelected()
    }
}

///////////////////////////////////////////////////////////

protocol TodoItemPrensentable{
    /////in protocol must have explicit {get} or {get set}
    var id: String? {get}
    var textValue: String? {get}
    /////added ep4////
    var isDone: Bool? {get set}
    var menuItems: [TodoMenuItemViewPresentable]? {get}
}

// if we put struct in the place struct, we must create contructer to execute
//  let item1 = TodoItemViewModel(id: "1", textValue: "washing clothes")
class TodoItemViewModel: TodoItemPrensentable {
    var id: String? = "0"
    var textValue: String?
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewModel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.parent = parentViewModel
        
        print("TodoItemViewModel: TodoItemPrensentable ")
        
        ///// added to swipe action ////////////////////////
        let removeMenuItem = RemoveMenuItemViewModel(parentViewModel: self)
        removeMenuItem.title = "Remove"
        removeMenuItem.backColor = "ff0000"
        
        
        let doneMenuItem = DoneMenuItemViewModel(parentViewModel: self)
         /////modified ep4////
        doneMenuItem.title = isDone! ? "Undone" : "Done"
        doneMenuItem.backColor = "000000"
        
        menuItems?.append(contentsOf: [removeMenuItem,doneMenuItem])
        /////////////////////////////////////////////////
    }
}

///////////////////////////////////////////////////////////////////////////////////

protocol TodoItemViewDelegate: class{
    func onItemSelected() -> (Void)
    func onRemoveSelected() -> (Void)
    func onDoneSelected() -> (Void)
}

extension TodoItemViewModel: TodoItemViewDelegate {
    
    //// on item selected received in view model on didSelectRowAt
    /// 
    func onItemSelected(){
        print (" did select row at received for item with id= \(id!)");
    }
    
    func onRemoveSelected() {
        parent?.onTodoDelete(todoId: id!)
    }
    func onDoneSelected() {
        parent?.onTodoDone(todoId: id!)
    }
}

////////////////////////////////////////////////////////////////////////////////////

protocol TodoViewPresentable{
    var newTodoItem: String? {get}
}

class TodoViewModel: TodoViewPresentable {
    
    /// ep5 deleted
    ///weak var view: TodoView?
    var newTodoItem: String?
    ///ep5 replace var items :  [TodoItemPrensentable] = [] with Variable...
    var items : Variable <[TodoItemPrensentable]> = Variable([])
    
    init() {
        let item1 = TodoItemViewModel(id: "1", textValue: "washing clothes", parentViewModel: self)
        let item2 = TodoItemViewModel(id: "2", textValue: "buy groceries", parentViewModel: self)
        let item3 = TodoItemViewModel(id: "3", textValue: "wash car", parentViewModel: self)
        items.value.append(contentsOf: [item1, item2, item3] )
        
        print("TodoViewModel: TodoViewPresentable")
    }
}

///////////////////////////////////////////////////////////////////////////////////

protocol TodoViewDelegate: class {
    func onAddTodoItem() -> ()
    /////changed
    func onTodoDelete(todoId: String) -> ()
    func onTodoDone(todoId: String) -> ()
}

// we use extention when we want to add some functionality to exist class, stuct, enum, protocole
extension TodoViewModel: TodoViewDelegate {
    
    func onAddTodoItem(){
        
        guard let newValue = newTodoItem else{
             print("new value is empty")
            return
        }
        
        print("new todoitem: \(newValue)")
        let itemIndex =  items.value.count+1
        let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewModel: self)
        self.items.value.append(newItem)
        
        self.newTodoItem = ""
        
        //// vider parameter method
        ////ep5 deleted
        ////self.view?.insertTodoItem()
    }
    
    func onTodoDelete(todoId: String){
        
        guard let index = self.items.value.index(where: {$0.id! == todoId }) else {
            print ("item for the index does not exist")
            return
        }
        self.items.value.remove(at: index)
        
        ///update view
        ///ep5 deleted
        ///self.view?.removeTodoItem(at: index)
    }
    
    func onTodoDone(todoId: String) {
        print("todo item done with id= \(todoId)")
        
        ///added ep4
        guard let index = self.items.value.index(where: {$0.id! == todoId }) else {
            print ("item for the index does not exist")
            return
        }
        var todoItem = self.items.value[index]
        todoItem.isDone = !(todoItem.isDone)!
        if var doneMenuItem = todoItem.menuItems?.filter({ (todoMenuItem) -> Bool in
            todoMenuItem is DoneMenuItemViewModel
        }).first{
            doneMenuItem.title =  todoItem.isDone! ? "Undone" : "Done"
        }
        self.items.value.sort(by: {
            /// added to sort the cells
            if !($0.isDone!) && !($1.isDone!) {
                return $0.id! < $01.id!
            }
            /////
            return !($0.isDone!) && $1.isDone!
        })
        //self.view?.updateTodoItem(at: index)
        /// replaced beacause updateTodoItem has bug
        /// ep5 deleted
        ///self.view?.reloadItems()
    }
}
