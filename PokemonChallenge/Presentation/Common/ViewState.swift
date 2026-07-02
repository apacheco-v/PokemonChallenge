import Foundation

enum ViewState<T> {
    case loading
    case loaded(T)
    case empty
    case error(String)
}

extension ViewState: Equatable where T: Equatable {}
