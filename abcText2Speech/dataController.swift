//
//  DataController.swift
//  abcText2Speech
//
//  Created by jaanvi Chirimar on 1/5/24.
//

import Foundation
import CoreData

class DataController: ObservableObject{

    static let shared = DataController()
    
    let container: NSPersistentContainer
    @Published var savedEntities: [UserEntity] = []    
    
    init(){
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        addUser(firstname: "firstn", lastname: "lastn", email: "test@terst", password: "pass")
        fetchUsers()
    }
    
    func fetchUsers() {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error while fetching: \(error)")
        }
    }
    
    func addUser(firstname: String, lastname: String, email: String, password: String) {
        let newUser = UserEntity(context: container.viewContext)
        newUser.firstname = firstname
        newUser.lastname = lastname
        newUser.email = email
        newUser.id = password
        saveData()
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchUsers()
        } catch let error {
            print("Error saving: \(error)")
        }
    }
}
