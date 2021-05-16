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
    private var characterList = [(id: Int, name: String)]()
    private let characterDAO = CharacterDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.characterList = self.characterDAO.find()
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
            
            if self.characterDAO.create(name: characterName) {
                self.characterList = self.characterDAO.find()
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

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.characterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }

        let character = self.characterList[indexPath.row]

        cell.textLabel?.text = character.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let character = self.characterList[indexPath.row]
        let id = character.id
        let name = character.name

        if editingStyle == .delete {
            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(name)\n삭제하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                if self.characterDAO.remove(id: id) {
                    self.characterList.remove(at: indexPath.row)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "characterDetailVC") else {
            return
        }
        
        let character = self.characterList[indexPath.row]
        let name = character.name
      
        nextVC.navigationItem.title = name
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.navigationController?.pushViewController(nextVC, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
