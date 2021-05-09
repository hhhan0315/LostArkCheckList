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
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "할 일"
            textField.clearButtonMode = .whileEditing
        })
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let todoName = alertController.textFields?[0].text else {
                return
            }
            var todoArray = self.userDefaults.stringArray(forKey: "todoArray") ?? []
            todoArray.append(todoName)
            
            self.userDefaults.setValue(todoArray, forKey: "todoArray")
            self.userDefaults.synchronize()
            self.tableView.reloadData()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let todoArray = self.userDefaults.stringArray(forKey: "todoArray") else {
            return 0
        }
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        
        let todoArray = self.userDefaults.stringArray(forKey: "todoArray")

        cell.textLabel?.text = todoArray?[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var todoArray = self.userDefaults.stringArray(forKey: "todoArray") else {
            return
        }
        let todoName = todoArray[indexPath.row]
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "할 일 삭제", message: "\(todoName) 삭제하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                todoArray.remove(at: indexPath.row)
                self.userDefaults.setValue(todoArray, forKey: "todoArray")
                self.userDefaults.synchronize()
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var todoArray = self.userDefaults.stringArray(forKey: "todoArray") else {
            return
        }
        
        todoArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.userDefaults.setValue(todoArray, forKey: "todoArray")
        self.userDefaults.synchronize()
    }
}
