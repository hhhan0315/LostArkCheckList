//
//  HomeViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/05.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let cellIdentifier = "homeCell"
    
    lazy var list: [NSManagedObject] = {
        return self.fetch()
    }()
    
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
        let alertController = UIAlertController(title: "캐릭터 추가", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let characterName = alertController.textFields?[0].text else {
                return
            }
            
            if self.save(name: characterName) == true {
                self.tableView.reloadData()
            }
        })
        
        okAction.isEnabled = false
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "캐릭터명"
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
    
    func fetch() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchResult = NSFetchRequest<NSManagedObject>(entityName: "Character")
        let result = try! context.fetch(fetchResult)
        return result
    }
    
    func save(name: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Character", into: context)
        object.setValue(name, forKey: "name")

        do {
            try context.save()
            self.list.append(object)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func delete(object: NSManagedObject) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
//    func move() -> Bool {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        
//        do {
//            try context.save()
//            return true
//        } catch {
//            context.rollback()
//            return false
//        }
//    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        
        let character = self.list[indexPath.row]
        let name = character.value(forKey: "name") as? String
        
        cell.textLabel?.text = name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let character = self.list[indexPath.row]
        guard let name = character.value(forKey: "name") as? String else {
            return
        }
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(name)\n삭제하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if self.delete(object: character) {
                    self.list.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let
//        self.list.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//        self.move()
//        print(self.list)
//        let sourceCharacter = self.list[sourceIndexPath.row]
//        let destinationCharacter = self.list[destinationIndexPath.row
        
        
//
//        characterArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//        self.userDefaults.setValue(characterArray, forKey: "characterArray")
//        self.userDefaults.synchronize()
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "characterDetailVC") else {
//            return
//        }
//
//        guard let characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
//            return
//        }
//
//        nextVC.navigationItem.title = characterArray[indexPath.row]
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//
//        self.navigationController?.pushViewController(nextVC, animated: true)
//        self.tableView.deselectRow(at: indexPath, animated: true)
//    }
}
