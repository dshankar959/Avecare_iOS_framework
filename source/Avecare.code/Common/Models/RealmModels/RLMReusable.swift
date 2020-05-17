import Foundation

protocol RLMReusable {
    // update unique fields, etc. (detach from realm first)
    func prepareForReuse()
}
