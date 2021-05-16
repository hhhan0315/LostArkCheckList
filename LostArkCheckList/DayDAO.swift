//
//  DayDAO.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/16.
//

struct DayVO {
    var dayId = 0
    var dayName = ""
    var dayIsDone = 0
    var characterId = 0
    var characterName = ""
}

class DayDAO {
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

    func find() -> [DayVO] {
        var dayList = [DayVO]()

        do {
            let sql = """
                SELECT day_id, day_name, day_isDone
                FROM day
                ORDER BY day.day_id ASC
                """
// JOIN character On character.character_id = 2 character.character_name
            let rs = try self.fmdb.executeQuery(sql, values: nil)

            while rs.next() {
                var record = DayVO()

                record.dayId = Int(rs.int(forColumn: "day_id"))
                record.dayName =  rs.string(forColumn: "day_name")!
                record.dayIsDone = Int(rs.int(forColumn: "day_isDone"))
//                record.characterName = rs.string(forColumn: "character_name")!
                
                dayList.append(record)
            }
        } catch let error as NSError {
            print("fail : \(error.localizedDescription)")
        }
        return dayList
    }

    func get(id: Int) -> DayVO? {
        let sql = """
            SELECT day_id, day_name, day_isDone
            FROM day
            WHERE day_id = ?
            """

        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [id])

        if let _rs = rs {
            _rs.next()
            var record = DayVO()
            
            record.dayId = Int(_rs.int(forColumn: "day_id"))
            record.dayName = _rs.string(forColumn: "day_name")!
            record.dayIsDone = Int(_rs.int(forColumn: "day_isDone"))
//            record.characterName = _rs.string(forColumn: "character_name")!

            return record
        } else {
            return nil
        }
    }

    func create(name: String) -> Bool {
        do {
            let sql = """
                INSERT INTO day (day_name)
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
            let sql = "DELETE FROM day WHERE day_id = ?"
            try self.fmdb.executeUpdate(sql, values: [id])
            return true
        } catch let error as NSError {
            print("Delete error: \(error.localizedDescription)")
            return false
        }
    }
}
