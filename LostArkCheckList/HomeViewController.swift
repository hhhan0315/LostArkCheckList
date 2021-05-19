//
//  HomeViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/05.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
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
            var characterArray = self.callCharacterArray()
            
            if characterArray.contains(characterName) {
                let alertController = UIAlertController(title: "이름 중복 오류", message: "다른 이름을 입력해주세요.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                characterArray.append(characterName)
            }
            
            self.saveCharacterArray(characterArray: characterArray)
            self.tableView.reloadData()
        })
        
        okAction.isEnabled = false
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "캐릭터명"
            textField.clearButtonMode = .whileEditing
            textField.font = UIFont.systemFont(ofSize: 18)
            
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
    
    @IBAction func touchUpRefreshButton(_ sender: UIBarButtonItem) {
        let characterArray = self.callCharacterArray()
        
        let actionController = UIAlertController(title: "전체 동기화 및 초기화", message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        actionController.addAction(UIAlertAction(title: "동기화", style: .default, handler: { _ in
            let alertController = UIAlertController(title: "전체 캐릭터 동기화", message: "동기화 및 초기화하겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                
                let todoDict = self.callTodoDict()
                for characterTitle in characterArray {
                    var characterDict = self.callCharacterDict(characterTitle: characterTitle)
                    
                    characterDict = todoDict
                    self.saveCharacterDict(characterDict: characterDict, characterTitle: characterTitle)
                }
                
                self.tableView.reloadData()
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "일일", style: .default, handler: { _ in
            self.makeAlertController(titleName: "일일", characterArray: characterArray)
        }))
        actionController.addAction(UIAlertAction(title: "주간", style: .default, handler: { _ in
            self.makeAlertController(titleName: "주간", characterArray: characterArray)
        }))
        actionController.addAction(UIAlertAction(title: "무기한", style: .default, handler: { _ in
            self.makeAlertController(titleName: "무기한", characterArray: characterArray)
        }))
        actionController.addAction(UIAlertAction(title: "모두", style: .default, handler: { _ in
            self.makeAlertController(titleName: "모두", characterArray: characterArray)
        }))
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    func makeAlertController(titleName: String, characterArray: [String]) {
        let alertController = UIAlertController(title: "전체 캐릭터 \(titleName) 초기화", message: "초기화하겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            for characterTitle in characterArray {
                var characterDict = self.callCharacterDict(characterTitle: characterTitle)
                
                if titleName == "모두" {
                    let sections = ["일일", "주간", "무기한"]
                    for section in sections {
                        guard let dict = characterDict?[section] else {
                            return
                        }

                        for i in 0..<dict.count {
                            characterDict?[section]?[i].isDone = false
                        }
                    }
                } else {
                    guard let dict = characterDict?[titleName] else {
                        return
                    }
                    for i in 0..<dict.count {
                        characterDict?[titleName]?[i].isDone = false
                    }
                }

                self.saveCharacterDict(characterDict: characterDict, characterTitle: characterTitle)
                self.tableView.reloadData()
            }
        }))

        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let characterArray = self.callCharacterArray()
        return characterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            return UITableViewCell()
        }
        let characterArray = self.callCharacterArray()
        
        cell.textLabel?.text = characterArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var characterArray = self.callCharacterArray()
        let characterName = characterArray[indexPath.row]
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(characterName) 삭제하겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                characterArray.remove(at: indexPath.row)
                
                UserDefaults.standard.removeObject(forKey: characterName)
                self.saveCharacterArray(characterArray: characterArray)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var characterArray = self.callCharacterArray()
        
        characterArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        self.saveCharacterArray(characterArray: characterArray)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "characterDetailVC") as? CharacterDetailViewController else {
            return
        }
        let characterArray = self.callCharacterArray()
        
        nextVC.characterTitle = characterArray[indexPath.row]
        nextVC.navigationItem.title = characterArray[indexPath.row]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(nextVC, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
