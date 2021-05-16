//
//  WeekDAO.swift
//  LostArkCheckList
//
//  Created by rae on 2021/05/16.
//

struct WeekVO {
    var weekId = 0
    var weekName = ""
    var weekIsDone = 0
    var characterId = 0
    var characterName = ""
}

class WeekDAO {
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

    func find() -> [WeekVO] {
        var weekList = [WeekVO]()

        do {
            let sql = """
                SELECT week_id, week_name, week_isDone
                FROM week
                ORDER BY week.week_id ASC
                """
// JOIN character On character.character_id = 2 character.character_name
            let rs = try self.fmdb.executeQuery(sql, values: nil)

            while rs.next() {
                var record = WeekVO()

                record.weekId = Int(rs.int(forColumn: "week_id"))
                record.weekName =  rs.string(forColumn: "week_name")!
                record.weekIsDone = Int(rs.int(forColumn: "week_isDone"))
//                record.characterName = rs.string(forColumn: "character_name")!
                
                weekList.append(record)
            }
        } catch let error as NSError {
            print("fail : \(error.localizedDescription)")
        }
        return weekList
    }

    func get(id: Int) -> WeekVO? {
        let sql = """
            SELECT week_id, week_name, week_isDone
            FROM week
            WHERE day_id = ?
            """

        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [id])

        if let _rs = rs {
            _rs.next()
            var record = WeekVO()

            record.weekId = Int(_rs.int(forColumn: "week_id"))
            record.weekName =  _rs.string(forColumn: "week_name")!
            record.weekIsDone = Int(_rs.int(forColumn: "week_isDone"))
//            record.characterName = _rs.string(forColumn: "character_name")!

            return record
        } else {
            return nil
        }
    }

    func create(name: String) -> Bool {
        do {
            let sql = """
                INSERT INTO week (week_name)
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
            let sql = "DELETE FROM week WHERE week_id = ?"
            try self.fmdb.executeUpdate(sql, values: [id])
            return true
        } catch let error as NSError {
            print("Delete error: \(error.localizedDescription)")
            return false
        }
    }
}
