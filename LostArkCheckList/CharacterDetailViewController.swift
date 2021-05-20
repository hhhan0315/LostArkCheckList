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
    private let todoSections = ["일일", "주간", "무기한"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setBarRightButtonItem()
    }
    
    func setBarRightButtonItem() {
        let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tapRefreshBarButton(_:)))
        self.navigationItem.rightBarButtonItem = refreshBarButton
    }
    
    @objc func tapRefreshBarButton(_ sender: UIBarButtonItem) {
        let actionController = UIAlertController(title: "\(self.characterTitle) 동기화 및 초기화", message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        actionController.addAction(UIAlertAction(title: "동기화", style: .default, handler: { _ in
            let alertController = UIAlertController(title: "동기화", message: "동기화 및 초기화하겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                
                let todoDict = self.callTodoDict()
                var characterDict = self.callCharacterDict(characterTitle: self.characterTitle)
                
                characterDict = todoDict
                
                self.saveCharacterDict(characterDict: characterDict, characterTitle: self.characterTitle)
                self.tableView.reloadData()
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }))
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
    
    @objc func tapCheckButton(_ sender: UIButton) {
        var characterDict = self.callCharacterDict(characterTitle: self.characterTitle)
        if sender.isSelected {
            sender.isSelected = false
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = false
        } else {
            sender.isSelected = true
            characterDict?[(sender.titleLabel?.text)!]?[sender.tag].isDone = true
        }
        self.saveCharacterDict(characterDict: characterDict, characterTitle: self.characterTitle)
        self.tableView.reloadData()
    }
    
    func makeAlertController(titleName: String) {
        let alertController = UIAlertController(title: "\(self.characterTitle) \(titleName) 초기화", message: "초기화하겠습니까?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            var characterDict = self.callCharacterDict(characterTitle: self.characterTitle)
            
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
            
            self.saveCharacterDict(characterDict: characterDict, characterTitle: self.characterTitle)
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
        let characterDict = self.callCharacterDict(characterTitle: self.characterTitle)
        let todoSectionName = todoSections[section]
        
        return characterDict?[todoSectionName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? CharacterDetailCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let characterDict = self.callCharacterDict(characterTitle: self.characterTitle)
        let todoSectionName = todoSections[indexPath.section]
        let isDone = characterDict?[todoSectionName]?[indexPath.row].isDone
        
        cell.textLabel?.text = characterDict?[todoSectionName]?[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        cell.checkButton.addTarget(self, action: #selector(tapCheckButton(_:)), for: .touchUpInside)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.titleLabel?.text = todoSectionName
        
        if isDone == true {
            cell.checkButton.isSelected = true
            cell.textLabel?.textColor = .lightGray
        } else if isDone == false {
            cell.checkButton.isSelected = false
            cell.textLabel?.textColor = .black
        }
        
        return cell
    }
}
