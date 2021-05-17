//
//  HomeViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/05.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let userDefaults = UserDefaults.standard
    private let cellIdentifier = "homeCell"
    
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
            var characterArray = self.userDefaults.stringArray(forKey: "characterArray") ?? []
            characterArray.append(characterName)
            
            self.userDefaults.setValue(characterArray, forKey: "characterArray")
            self.userDefaults.synchronize()
            self.tableView.reloadData()
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
        guard let characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return 0
        }
        return characterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        guard let characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = characterArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return
        }
        let characterName = characterArray[indexPath.row]
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(characterName)\n삭제하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                characterArray.remove(at: indexPath.row)
                self.userDefaults.removeObject(forKey: characterName)
                self.userDefaults.setValue(characterArray, forKey: "characterArray")
                self.userDefaults.synchronize()
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return
        }
        
        characterArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.userDefaults.setValue(characterArray, forKey: "characterArray")
        self.userDefaults.synchronize()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "characterDetailVC") as? CharacterDetailViewController else {
            return
        }
        
        guard let characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return
        }
        
        nextVC.characterTitle = characterArray[indexPath.row]
        nextVC.navigationItem.title = characterArray[indexPath.row]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.pushViewController(nextVC, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
