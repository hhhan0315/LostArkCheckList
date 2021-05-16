//
//  CharacterDAO.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/16.
//

class CharacterDAO {
    typealias CharacterRecord = (Int, String)
    
    lazy var fmdb: FMDatabase! = {
        let fileManager = FileManager.default
        
        let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let dbPath = docPath?.appendingPathComponent("LostArkDB.db").path else {
            return nil
        }
        
        if fileManager.fileExists(atPath: dbPath) == false {
            guard let dbSource = Bundle.main.path(forResource: "LostArkDB", ofType: "db") else {
                return nil
            }
            try! fileManager.copyItem(atPath: dbSource, toPath: dbPath)
        }
        
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    func find() -> [CharacterRecord] {
        var characterList = [CharacterRecord]()
        
        do {
            let sql = """
                SELECT character_id, character_name
                FROM character
                ORDER BY character_id ASC
                """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            while rs.next() {
                let id = rs.int(forColumn: "character_id")
                if let name = rs.string(forColumn: "character_name") {
                    characterList.append(( Int(id), name ))
                }
            }
        } catch let error as NSError {
            print("fail : \(error.localizedDescription)")
        }
        return characterList
    }
    
    func get(id: Int) -> CharacterRecord? {
        let sql = """
            SELECT character_id, character_name
            FROM character
            WHERE id = ?
            """
        
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [id])
        
        if let _rs = rs {
            _rs.next()
            
            let id = _rs.int(forColumn: "character_id")
            guard let name = _rs.string(forColumn: "character_name") else {
                return nil
            }
            
            return (Int(id), name)
        } else {
            return nil
        }
    }
    
    func create(name: String) -> Bool {
        do {
            let sql = """
                INSERT INTO character (character_name)
                VALUES (?)
                """
            try self.fmdb.executeUpdate(sql, values: [name])
            return true
        } catch let error as NSError {
            print("Insert error: \(error.localizedDescription)")
            return false
        }
    }
    
    func remove(id: Int) -> Bool {
        do {
            let sql = "DELETE FROM character WHERE character_id = ?"
            try self.fmdb.executeUpdate(sql, values: [id])
            return true
        } catch let error as NSError {
            print("Delete error: \(error.localizedDescription)")
            return false
        }
    }
}
