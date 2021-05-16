//
//  IndefineDAO.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/16.
//

struct IndefineVO {
    var indefineId = 0
    var indefineName = ""
    var indefineIsDone = 0
    var characterId = 0
    var characterName = ""
}

class IndefineDAO {
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

    func find() -> [IndefineVO] {
        var indefineList = [IndefineVO]()

        do {
            let sql = """
                SELECT indefine_id, indefine_name, indefine_isDone
                FROM indefine
                ORDER BY indefine.indefine_id ASC
                """
// JOIN character On character.character_id = 2 character.character_name
            let rs = try self.fmdb.executeQuery(sql, values: nil)

            while rs.next() {
                var record = IndefineVO()

                record.indefineId = Int(rs.int(forColumn: "indefine_id"))
                record.indefineName =  rs.string(forColumn: "indefine_name")!
                record.indefineIsDone = Int(rs.int(forColumn: "indefine_isDone"))
//                record.characterName = rs.string(forColumn: "character_name")!
                
                indefineList.append(record)
            }
        } catch let error as NSError {
            print("fail : \(error.localizedDescription)")
        }
        return indefineList
    }

    func get(id: Int) -> IndefineVO? {
        let sql = """
            SELECT indefine_id, indefine_name, indefine_isDone
            FROM indefine
            WHERE indefine_id = ?
            """

        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [id])

        if let _rs = rs {
            _rs.next()
            var record = IndefineVO()

            record.indefineId = Int(_rs.int(forColumn: "indefine_id"))
            record.indefineName =  _rs.string(forColumn: "indefine_name")!
            record.indefineIsDone = Int(_rs.int(forColumn: "indefine_isDone"))
//            record.characterName = _rs.string(forColumn: "character_name")!

            return record
        } else {
            return nil
        }
    }

    func create(name: String) -> Bool {
        do {
            let sql = """
                INSERT INTO indefine (indefine_name)
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
            let sql = "DELETE FROM indefine WHERE indefine_id = ?"
            try self.fmdb.executeUpdate(sql, values: [id])
            return true
        } catch let error as NSError {
            print("Delete error: \(error.localizedDescription)")
            return false
        }
    }
}
