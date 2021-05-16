//
//  ToDoViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/09.
//

import UIKit
import CoreData

class ToDoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let cellIdentifier = "todoCell"
    private let todoSections = ["일일", "주간", "무기한"]
    private var todoSection = String()
    private let todoEnglishNames = ["Day", "Week", "Indefine"]
    
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
        
        self.todoSection = self.todoEnglishNames[choiceRowNum]
        
        contentView.view = pickerView
        contentView.preferredContentSize.height = 120
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let todoName = alertController.textFields?[0].text else {
                return
            }
            
//            if self.save(entityName: self.todoSection, name: todoName) == true {
//                self.tableView.reloadData()
//            }
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
//        switch section {
//        case 0:
//            return self.dayList.count
//        case 1:
//            return self.weekList.count
//        case 2:
//            return self.indefineList.count
//        default:
//            return 0
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
//        var todo: NSManagedObject?
//
//        switch indexPath.section {
//        case 0:
//            todo = self.dayList[indexPath.row]
//        case 1:
//            todo = self.weekList[indexPath.row]
//        case 2:
//            todo = self.indefineList[indexPath.row]
//        default:
//            break
//        }
//
//        let name = todo?.value(forKey: "name") as? String
//        cell.textLabel?.text = name
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
//
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        var todo: NSManagedObject?
//        
//        switch indexPath.section {
//        case 0:
//            todo = self.dayList[indexPath.row]
//        case 1:
//            todo = self.weekList[indexPath.row]
//        case 2:
//            todo = self.indefineList[indexPath.row]
//        default:
//            break
//        }
//        
//        guard let name = todo?.value(forKey: "name") as? String else {
//            return
//        }
//        
//        guard let todoObj = todo else {
//            return
//        }
//
//        if editingStyle == .delete {
//            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(name)\n삭제하시겠습니까?", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
//            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                if self.delete(object: todoObj) {
//                    switch indexPath.section {
//                    case 0:
//                        self.dayList.remove(at: indexPath.row)
//                    case 1:
//                        self.weekList.remove(at: indexPath.row)
//                    case 2:
//                        self.indefineList.remove(at: indexPath.row)
//                    default:
//                        break
//                    }
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
//                }
//            }))
//
//            self.present(alertController, animated: true, completion: nil)
//        }
    }
    
    //    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //        guard var todoDict = self.userDefaults.dictionary(forKey: "todoDict") as? [String: [String]] else {
    //            return
    //        }
    //
    //        let sourceSectionName = todoSections[sourceIndexPath.section]
    //        let destinationSectionName = todoSections[destinationIndexPath.section]
    //        let sourceName = todoDict[sourceSectionName]?[sourceIndexPath.row]
    //
    //        todoDict[sourceSectionName]?.remove(at: sourceIndexPath.row)
    //        todoDict[destinationSectionName]?.insert(sourceName!, at: destinationIndexPath.row)
    //
    //        self.userDefaults.setValue(todoDict, forKey: "todoDict")
    //        self.userDefaults.synchronize()
    //    }
    
    
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
            self.todoSection = self.todoEnglishNames[row]
        case 1:
            self.todoSection = self.todoEnglishNames[row]
        case 2:
            self.todoSection = self.todoEnglishNames[row]
        default:
            return
        }
    }
}
