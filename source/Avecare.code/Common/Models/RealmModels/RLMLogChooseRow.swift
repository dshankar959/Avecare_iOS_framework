import Foundation
import RealmSwift



// Logs -> list of available form rows for + picker
class RLMLogChooseRow: Object, Decodable {

    @objc dynamic var name = ""
    @objc dynamic var row: RLMLogRow?


    enum CodingKeys: String, CodingKey {
        case name
        case rowType
        case properties
    }


    override class func primaryKey() -> String? {
        return "name"
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        guard let type = RLMLogRow.RowType(rawValue: try container.decode(Int.self, forKey: .rowType)) else {
            throw JSONError.invalidRowTypeId.message
        }

        switch type {
        case .option: row = try RLMLogRow(row: try container.decode(RLMLogOptionRow.self, forKey: .properties))
        case .time: row = try RLMLogRow(row: try container.decode(RLMLogTimeRow.self, forKey: .properties))
        case .switcher: row = try RLMLogRow(row: try container.decode(RLMLogSwitcherRow.self, forKey: .properties))
        case .note: row = try RLMLogRow(row: try container.decode(RLMLogNoteRow.self, forKey: .properties))
        case .photo: row = try RLMLogRow(row: try container.decode(RLMLogPhotoRow.self, forKey: .properties))
        case .injury: row = try RLMLogRow(row: try container.decode(RLMLogInjuryRow.self, forKey: .properties))
        }

    }
}


extension RLMLogChooseRow: DataProvider, RLMCleanable {
    typealias T = RLMLogChooseRow

    func clean() {
        let allLogChooseRows: [RLMLogChooseRow] = RLMLogChooseRow().findAll()

        for rowObject in allLogChooseRows {
            rowObject.row?.clean()
            rowObject.delete()
//            RLMLogChooseRow().delete(object: rowObject)
        }
    }

}


extension RLMLogChooseRow: SingleValuePickerItem {
    var pickerTextValue: String {
        return name
    }
}
