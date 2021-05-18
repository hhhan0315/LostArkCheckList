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
        
        let rightBarButton = UIBarButtonItem(title: "동기화", style: .plain, target: self, action: #selector(tapRightBarButton(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func tapRightBarButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "동기화", message: "할 일을 동기화 하시겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            
            var todoDict: [String:[Todo]]?
            var characterDict = self.callCharacterDict()
            
            if let todoData = UserDefaults.standard.value(forKey:"todoDict") as? Data {
                todoDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: todoData)
            }
            
            characterDict = todoDict
            
            self.userDefaults.set(try? PropertyListEncoder().encode(characterDict), forKey: self.characterTitle)
            self.userDefaults.synchronize()
            self.tableView.reloadData()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func callCharacterDict() -> [String:[Todo]]? {
        var characterDict: [String:[Todo]]? = [:]
        if let characterData = UserDefaults.standard.value(forKey:self.characterTitle) as? Data {
            characterDict = try? PropertyListDecoder().decode([String:[Todo]].self, from: characterData)
        }
        return characterDict
    }
    
    @objc func touchUpButton(_ sender: UIButton) {
        var characterDict = self.callCharacterDict()
        if sender.isSelected {
            sender.isSelected = false
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = false
            self.userDefaults.set(try? PropertyListEncoder().encode(characterDict), forKey: self.characterTitle)
        } else {
            sender.isSelected = true
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = true
            self.userDefaults.set(try? PropertyListEncoder().encode(characterDict), forKey: self.characterTitle)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
