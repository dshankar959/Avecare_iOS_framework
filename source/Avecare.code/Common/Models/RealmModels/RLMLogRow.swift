import CocoaLumberjack
import RealmSwift



class RLMLogRow: Object, Decodable {
    /*
    switch self {
    case .option: return RLMLogOptionRow.self
    case .time: return RLMLogTimeRow.self
    case .switcher: return RLMLogSwitcherRow.self
    case .note: return RLMLogNoteRow.self
    case .photo: return RLMLogPhotoRow.self
    case .injury: return RLMLogInjuryRow.self
    }
    */
    enum RowType: Int, CustomStringConvertible {
        case option = 1
        case time = 2
        case switcher = 3
        case note = 4
        case photo = 5
        case injury = 6

        static var all: [RowType] {
            return [.option, .time, .switcher, .note, .photo, .injury]
        }

        var description: String {
            switch self {
            case .option: return "Option"
            case .time: return "Time"
            case .switcher: return "Time and Switcher"
            case .note: return "Note"
            case .photo: return "Photo with Caption"
            case .injury: return "Injury"
            }
        }
    }

    var rowType: RowType {
        if option != nil {
            return .option
        } else if time != nil {
            return .time
        } else if switcher != nil {
            return .switcher
        } else if note != nil {
            return .note
        } else if photo != nil {
            return .photo
        } else if injury != nil {
            return .injury
        } else {
            fatalError()
        }
    }

    @objc dynamic var option: RLMLogOptionRow?
    @objc dynamic var time: RLMLogTimeRow?
    @objc dynamic var switcher: RLMLogSwitcherRow?
    @objc dynamic var note: RLMLogNoteRow?
    @objc dynamic var photo: RLMLogPhotoRow?
    @objc dynamic var injury: RLMLogInjuryRow?

    convenience init<T: Object>(row: T) throws {
        self.init()
        switch type(of: row) {
        case is RLMLogOptionRow.Type:   option = row as? RLMLogOptionRow
        case is RLMLogTimeRow.Type:     time = row as? RLMLogTimeRow
        case is RLMLogSwitcherRow.Type: switcher = row as? RLMLogSwitcherRow
        case is RLMLogNoteRow.Type:     note = row as? RLMLogNoteRow
        case is RLMLogPhotoRow.Type:    photo = row as? RLMLogPhotoRow
        case is RLMLogInjuryRow.Type:   injury = row as? RLMLogInjuryRow
        default: throw RealmError.invalidRowObject.message
        }
    }

    enum CodingKeys: String, CodingKey {
        case rowType
        case properties
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            guard let type = RLMLogRow.RowType(rawValue: try values.decode(Int.self, forKey: .rowType)) else {
                throw JSONError.invalidRowTypeId.message
            }

            switch type {
            case .option: option = try values.decode(RLMLogOptionRow.self, forKey: .properties)
            case .time: time = try values.decode(RLMLogTimeRow.self, forKey: .properties)
            case .switcher: switcher = try values.decode(RLMLogSwitcherRow.self, forKey: .properties)
            case .note: note = try values.decode(RLMLogNoteRow.self, forKey: .properties)
            case .photo: photo = try values.decode(RLMLogPhotoRow.self, forKey: .properties)
            case .injury: injury = try values.decode(RLMLogInjuryRow.self, forKey: .properties)
            }

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }


}


extension RLMLogRow: DataProvider, RLMCleanable {
    typealias T = RLMLogRow

    func clean() {
        if let option = option {
            option.clean()
        } else if let time = time {
            time.delete()
        } else if let switcher = switcher {
            switcher.clean()
        } else if let note = note {
            note.delete()
        } else if let photo = photo {
            photo.clean()
        } else if let injury = injury {
            injury.delete()
        }

        delete()
   }

}
