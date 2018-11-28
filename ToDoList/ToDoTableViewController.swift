//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Sander de Vries on 27/11/2018.
//  Copyright © 2018 Sander de Vries. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    var todos = [ToDo]()
    
    @IBOutlet weak var isCompleteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedToDos = ToDo.loadToDos() {
            todos = savedToDos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var todo = todos[indexPath.row]
            todo.isComplete = !todo.isComplete
            todos[indexPath.row] = todo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(todos)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier") as? ToDoCell else {
            fatalError("Could not dequeue a cell")
        }
        
        let todo = todos[indexPath.row]
        cell.titleLabel?.text = todo.title
        cell.isCompleteButton.isSelected = todo.isComplete
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            ToDo.saveToDos(todos)
        }
    }
    
    @IBAction func unwindToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let svc = segue.source as! ToDoViewController
        
        if let todo = svc.todo {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                todos[selectedIndexPath.row] = todo
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                
                let newIndexPath = IndexPath(row: todos.count, section: 0)
                todos.append(todo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(todos)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let toDoVC = segue.destination as! ToDoViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedToDo = todos[indexPath.row]
            toDoVC.todo = selectedToDo
        }
    }
}
