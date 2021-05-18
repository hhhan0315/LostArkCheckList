//
//  CharacterDetailViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/11.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var characterTitle = ""
    private let cellIdentifier = "characterDetailCell"
    private let userDefaults = UserDefaults.standard
    private let todoSections = ["일일", "주간", "무기한"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setBarRightButtonItem()
    }
    
    func setBarRightButtonItem() {
        let syncBarButton = UIBarButtonItem(title: "동기화", style: .plain, target: self, action: #selector(tapSyncBarButton(_:)))
        let clearBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tapClearBarButton(_:)))
        self.navigationItem.rightBarButtonItems = [clearBarButton, syncBarButton]
    }
    
    @objc func tapSyncBarButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "동기화", message: "할 일을 동기화 하시겠습니까?\n체크사항이 모두 초기화됩니다.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            
            let todoDict = self.callTodoDict()
            var characterDict = self.callCharacterDict()
            
            characterDict = todoDict
            
            self.saveCharacterDict(characterDict: characterDict)
            self.tableView.reloadData()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func tapClearBarButton(_ sender: UIBarButtonItem) {
        let actionController = UIAlertController(title: "초기화", message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        actionController.addAction(UIAlertAction(title: "일일", style: .default, handler: { _ in
            self.makeAlertController(titleName: "일일")
        }))
        actionController.addAction(UIAlertAction(title: "주간", style: .default, handler: { _ in
            self.makeAlertController(titleName: "주간")
        }))
        actionController.addAction(UIAlertAction(title: "무기한", style: .default, handler: { _ in
            self.makeAlertController(titleName: "무기한")
        }))
        actionController.addAction(UIAlertAction(title: "모두", style: .default, handler: { _ in
            self.makeAlertController(titleName: "모두")
        }))
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    func callCharacterDict() -> [String:[Todo]]? {
        var characterDict: [String:[Todo]]? = [:]
        if let characterData = UserDefaults.standard.value(forKey:self.characterTitle) as? Data {
            characterDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: characterData)
        }
        return characterDict
    }
    
    func saveCharacterDict(characterDict: [String:[Todo]]?) {
        self.userDefaults.set(try? PropertyListEncoder().encode(characterDict), forKey: self.characterTitle)
        self.userDefaults.synchronize()
    }
    
    func callTodoDict() -> [String:[Todo]]? {
        var todoDict: [String:[Todo]]? = [:]
        if let todoData = UserDefaults.standard.value(forKey:"todoDict") as? Data {
            todoDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: todoData)
        }
        return todoDict
    }
    
    @objc func touchUpButton(_ sender: UIButton) {
        var characterDict = self.callCharacterDict()
        if sender.isSelected {
            sender.isSelected = false
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = false
        } else {
            sender.isSelected = true
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = true
        }
        self.saveCharacterDict(characterDict: characterDict)
        self.tableView.reloadData()
    }
    
    func makeAlertController(titleName: String) {
        let alertController = UIAlertController(title: "\(titleName) 초기화", message: "초기화하시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            var characterDict = self.callCharacterDict()
            
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
            
            self.saveCharacterDict(characterDict: characterDict)
            self.tableView.reloadData()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CharacterDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return todoSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let characterDict = self.callCharacterDict()
        let todoSectionName = todoSections[section]
        
        return characterDict?[todoSectionName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? CharacterDetailCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let characterDict = self.callCharacterDict()
        let todoSectionName = todoSections[indexPath.section]
        let isDone = characterDict?[todoSectionName]?[indexPath.row].isDone
        
        cell.textLabel?.text = characterDict?[todoSectionName]?[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        cell.checkButton.addTarget(self, action: #selector(touchUpButton(_:)), for: .touchUpInside)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.titleLabel?.text = todoSectionName
        
        if isDone == true {
            cell.checkButton.isSelected = true
        } else if isDone == false {
            cell.checkButton.isSelected = false
        }
        
        return cell
    }
}
