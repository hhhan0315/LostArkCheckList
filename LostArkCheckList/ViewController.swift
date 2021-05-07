//
//  ViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/05.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let userDefaults = UserDefaults.standard
    private let cellIdentifier = "characterCell"
    
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
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "캐릭터명"
        })
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            guard let characterName = alertController.textFields?[0].text else {
                return
            }
            var characterArray = self.userDefaults.stringArray(forKey: "characterArray") ?? []
            characterArray.append(characterName)
            
            self.userDefaults.setValue(characterArray, forKey: "characterArray")
            self.userDefaults.synchronize()
            self.tableView.reloadData()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
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
        let characterArray = self.userDefaults.stringArray(forKey: "characterArray")

        cell.textLabel?.text = characterArray?[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var characterArray = self.userDefaults.stringArray(forKey: "characterArray") else {
            return
        }
        let characterName = characterArray[indexPath.row]
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "캐릭터 삭제", message: "\(characterName) 삭제하시겠습니까?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                characterArray.remove(at: indexPath.row)
                self.userDefaults.setValue(characterArray, forKey: "characterArray")
                self.userDefaults.synchronize()
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
