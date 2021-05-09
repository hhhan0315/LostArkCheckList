//
//  AlertListViewController.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/09.
//

import UIKit

class AlertListViewController: UITableViewController {
    private let todoChoices = ["일일", "주간", "무기한"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize.height = 130.5
        self.tableView.isScrollEnabled = false
        self.tableView.separatorInset = .zero
        self.tableView.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoChoices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        
        cell.textLabel?.text = todoChoices[indexPath.row]
        cell.textLabel?.textAlignment = .center
         
        return cell
    }
    
}
