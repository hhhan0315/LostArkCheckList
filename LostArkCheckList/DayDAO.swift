////
////  DayDAO.swift
////  LostArkCheckList
////
////  Created by rae on 2021/05/16.
////
//
//class DayDAO {
//    struct DayVO {
//        var id = 0
//        var name = ""
//        var isDone = 0
//        var characterId = 0
//        var characterName = ""
//    }
//    
//    lazy var fmdb: FMDatabase! = {
//        let fileManager = FileManager.default
//        
//        let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//        guard let dbPath = docPath?.appendingPathComponent("LostArkDB.db").path else {
//            return nil
//        }
//        
//        if fileManager.fileExists(atPath: dbPath) == false {
//            guard let dbSource = Bundle.main.path(forResource: "LostArkDB", ofType: "db") else {
//                return nil
//            }
//            try! fileManager.copyItem(atPath: dbSource, toPath: dbPath)
//        }
//        
//        let db = FMDatabase(path: dbPath)
//        return db
//    }()
//    
//    init() {
//        self.fmdb.open()
//    }
//    
//    deinit {
//        self.fmdb.close()
//    }
//    
//    func find() -> [DayVO] {
//        var characterList = [DayVO]()
//        
//        do {
//            let sql = """
//                SELECT id, name, isDone, character_id,
//                character.name
//                FROM day
//                JOIN character On character.id = day.id
//                ORDER BY day.character_id ASC
//                """
//            
//            let rs = try self.fmdb.executeQuery(sql, values: nil)
//            
//            while rs.next() {
//                var record = DayVO()
//                
//                record.id = Int(rs.int(forColumn: "id"))
//                record.name =  rs.string(forColumn: "name")
//                record.isDone = Int(rs.int(forColumn: "isDone"))
//                record.characterId = Int(rs.int(forColumn: "character_id"))
//                record.characterName = rs.string(forColumn: "name")
//            }
//        } catch let error as NSError {
//            print("fail : \(error.localizedDescription)")
//        }
//        return characterList
//    }
//    
//    func get(id: Int) -> CharacterRecord? {
//        let sql = """
//            SELECT id, name
//            FROM character
//            WHERE id = ?
//            """
//        
//        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [id])
//        
//        if let _rs = rs {
//            _rs.next()
//            
//            let id = _rs.int(forColumn: "id")
//            guard let name = _rs.string(forColumn: "name") else {
//                return nil
//            }
//            
//            return (Int(id), name)
//        } else {
//            return nil
//        }
//    }
//    
//    func create(name: String) -> Bool {
//        do {
//            let sql = """
//                INSERT INTO character (name)
//                VALUES (?)
//                """
//            try self.fmdb.executeUpdate(sql, values: [name])
//            return true
//        } catch let error as NSError {
//            print("Insert error: \(error.localizedDescription)")
//            return false
//        }
//    }
//    
//    func remove(id: Int) -> Bool {
//        do {
//            let sql = "DELETE FROM character WHERE id = ?"
//            try self.fmdb.executeUpdate(sql, values: [id])
//            return true
//        } catch let error as NSError {
//            print("Delete error: \(error.localizedDescription)")
//            return false
//        }
//    }
//}
