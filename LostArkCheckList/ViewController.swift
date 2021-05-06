//
//  ViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/05.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var toDoTableView: UITableView!
    private let toDoCellIdentifier = "toDoCell"
    private var toDo = ["카오스 던전", "주간 레이드"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoTableView.delegate = self
        toDoTableView.dataSource = self
    }

    @IBAction func touchUpAddButton(_ sender: UIBarButtonItem) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        actionController.addAction(UIAlertAction(title: "캐릭터 추가", style: .default, handler: { _ in
            let alertController = UIAlertController(title: "캐릭터 추가", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
//                print(alertController.textFields?[0].text)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "할 일 추가", style: .default, handler: { _ in
            let alertController = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
//                print(alertController.textFields?[0].text)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }))
        
        self.present(actionController, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.toDo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.toDoCellIdentifier) else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = toDo[indexPath.row]
        
        return cell
    }
    
    
}
