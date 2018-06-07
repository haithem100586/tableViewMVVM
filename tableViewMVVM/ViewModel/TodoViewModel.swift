//
//  TodoViewModel.swift
//  tableViewMVVM
//
//  Created by Macbook on 07/02/2018.
//  Copyright © 2018 HE. All rights reserved.
//


protocol TodoItemPrensentable{
    /////in protocol must have explicit {get} or {get set}
    var id: String? {get}
    var textValue: String? {get}
}

// if we put struct in the place struct, we must create contructer to execute
//  let item1 = TodoItemViewModel(id: "1", textValue: "washing clothes")
class TodoItemViewModel: TodoItemPrensentable {
    var id: String? = "0"
    var textValue: String?
    
    init(id: String, textValue: String) {
        self.id = id
        self.textValue = textValue
    }
}


protocol TodoViewPresentable{
    var newTodoItem: String? {get}
}

class TodoViewModel: TodoViewPresentable {
    
    weak var view: TodoView?
    var newTodoItem: String?
    var items : [TodoItemPrensentable] = []
    
    init(view: TodoView) {
        self.view = view
        let item1 = TodoItemViewModel(id: "1", textValue: "washing clothes")
        let item2 = TodoItemViewModel(id: "2", textValue: "buy groceries")
        let item3 = TodoItemViewModel(id: "3", textValue: "wash car")
        items.append(contentsOf: [item1, item2, item3] )
    }
}


protocol TodoViewDelegate{
    func onAddTodoItem (newValue: String) -> ()
}

// we use extention when we want to add some functionality to exist class, stuct, enum, protocole
extension TodoViewModel: TodoViewDelegate {
    
    func onAddTodoItem(newValue: String){
        
        print("new todoitem: \(newValue)")
        let itemIndex =  items.count+1
        let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue)
        self.items.append(newItem)
        self.view?.insertTodoItem()
    }
}
