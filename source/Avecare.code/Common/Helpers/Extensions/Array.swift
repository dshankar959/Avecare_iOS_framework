
// Removing duplicate elements from an array in Swift
// https://stackoverflow.com/a/60995069/7599
extension Array where Element: Hashable {

    var uniqueValues: [Element] {
        var allowed = Set(self)
        return compactMap { allowed.remove($0) }
    }

}
