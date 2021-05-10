//
//  ToDoViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/09.
//

import UIKit

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let userDefaults = UserDefaults.standard
    private let cellIdentifier = "todoCell"
    private let todoChoices = ["일일", "주간", "무기한"]
    
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
        let contentView = AlertListViewController()
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let todoName = alertController.textFields?[0].text else {
                return
            }
            let todoChoice = contentView.todoChoice
            var todoDict = self.userDefaults.dictionary(forKey: "todoDict") as? [String: [String]] ?? [:]
            
            if !todoDict.keys.contains(todoChoice) {
                todoDict[todoChoice] = [todoName]
            } else {
                todoDict[todoChoice]?.append(todoName)
            }
            
            self.userDefaults.setValue(todoDict, forKey: "todoDict")
            self.userDefaults.synchronize()
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
//        guard let todoDict = self.userDefaults.dictionary(forKey: "todoDict") else {
//            return 0
//        }
//        return todoDict.count
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return todoChoices[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let todoDict = self.userDefaults.dictionary(forKey: "todoDict") as? [String: [String]] else {
            return 0
        }

        if section == 0 {
            return todoDict["일일"]?.count ?? 0
        } else if section == 1 {
            return todoDict["주간"]?.count ?? 0
        } else if section == 2 {
            return todoDict["무기한"]?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        
        guard let todoDict = self.userDefaults.dictionary(forKey: "todoDict") as? [String: [String]] else {
            return UITableViewCell()
        }

        if indexPath.section == 0 {
            cell.textLabel?.text = todoDict["일일"]?[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = todoDict["주간"]?[indexPath.row]
        } else if indexPath.section == 2 {
            cell.textLabel?.text = todoDict["무기한"]?[indexPath.row]
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        guard var todoArray = self.userDefaults.stringArray(forKey: "todoArray") else {
//            return
//        }
//        let todoName = todoArray[indexPath.row]
//
//        if editingStyle == .delete {
//            let alertController = UIAlertController(title: "할 일 삭제", message: "\(todoName) 삭제하시겠습니까?", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
//            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                todoArray.remove(at: indexPath.row)
//                self.userDefaults.setValue(todoArray, forKey: "todoArray")
//                self.userDefaults.synchronize()
//                self.tableView.deleteRows(at: [indexPath], with: .fade)
//            }))
//
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard var todoArray = self.userDefaults.stringArray(forKey: "todoArray") else {
//            return
//        }
//
//        todoArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//        self.userDefaults.setValue(todoArray, forKey: "todoArray")
//        self.userDefaults.synchronize()
//    }
    
    
}
