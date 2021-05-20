//
//  ToDoViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/09.
//

import UIKit

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let cellIdentifier = "todoCell"
    private let todoSections = ["일일", "주간", "무기한"]
    private var todoSection = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func touchUpEditButton(_ sender: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
            sender.title = "편집"
        } else {
            self.tableView.setEditing(true, animated: true)
            sender.title = "완료"
        }
    }
    
    @IBAction func touchUpAddButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
        let contentView = UIViewController()
        let pickerView = UIPickerView()
        let choiceRowNum = 1
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(choiceRowNum, inComponent: 0, animated: true)
        self.todoSection = self.todoSections[choiceRowNum]
        
        contentView.view = pickerView
        contentView.preferredContentSize.height = 140
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let todoName = alertController.textFields?[0].text else {
                return
            }
            
            var todoDict = self.callTodoDict()
            let todo = Todo(name: todoName, isDone: false)
            
            if todoDict?.keys.contains(self.todoSection) == false {
                todoDict?[self.todoSection] = [todo]
            } else {
                todoDict?[self.todoSection]?.append(todo)
            }
            
            self.saveTodoDict(todoDict: todoDict)
            self.tableView.reloadData()
        })
        okAction.isEnabled = false
        
        alertController.setValue(contentView, forKey: "contentViewController")
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "할 일"
            textField.clearButtonMode = .whileEditing
            textField.font = UIFont.systemFont(ofSize: 16)
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespaces).count ?? 0
                let textIsNotEmpty = textCount > 0
                
                okAction.isEnabled = textIsNotEmpty
            })
        })
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return todoSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let todoDict = self.callTodoDict()
        let todoSectionName = todoSections[section]
        
        return todoDict?[todoSectionName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let todoDict = self.callTodoDict()
        let todoSectionName = todoSections[indexPath.section]
        
        cell.textLabel?.text = todoDict?[todoSectionName]?[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var todoDict = self.callTodoDict()
        let todoSectionName = todoSections[indexPath.section]
        let todoName = todoDict?[todoSectionName]?[indexPath.row].name ?? ""
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "할 일 삭제", message: "\(todoName) 삭제하겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                todoDict?[todoSectionName]?.remove(at: indexPath.row)
                self.saveTodoDict(todoDict: todoDict)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var todoDict = self.callTodoDict()
        
        let sourceSectionName = todoSections[sourceIndexPath.section]
        let destinationSectionName = todoSections[destinationIndexPath.section]
        guard let sourceName = todoDict?[sourceSectionName]?[sourceIndexPath.row] else {
            return
        }
        
        todoDict?[sourceSectionName]?.remove(at: sourceIndexPath.row)
        todoDict?[destinationSectionName]?.insert(sourceName, at: destinationIndexPath.row)
        
        self.saveTodoDict(todoDict: todoDict)
    }
}

// MARK:- UIPickerViewDelegate, UIPickerViewDataSource
extension ToDoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.todoSections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.todoSections[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            self.todoSection = self.todoSections[row]
        case 1:
            self.todoSection = self.todoSections[row]
        case 2:
            self.todoSection = self.todoSections[row]
        default:
            return
        }
    }
}
