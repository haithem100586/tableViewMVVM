//
//  TodoItemTableViewCell.swift
//  tableViewMVVM
//
//  Created by Macbook on 07/02/2018.
//  Copyright © 2018 HE. All rights reserved.
//

import UIKit


class TodoItemTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var txtIndex: UILabel!
    
    @IBOutlet weak var txtTodoItem: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure (withViewModel  viewModel: TodoItemPrensentable) -> (Void){
    
        txtIndex.text = viewModel.id!
        //deleted ep4
        //txtTodoItem.text = viewModel.textValue
 
        ///added ep4
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: viewModel.textValue!)
        if viewModel.isDone! {
            let range = NSMakeRange(0, attributeString.length)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughColor, value: UIColor.lightGray, range: range)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: range)
            attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray, range: range)
        }
        
        //added here ep4
        txtTodoItem.attributedText = attributeString
        
    }
    
    
}
