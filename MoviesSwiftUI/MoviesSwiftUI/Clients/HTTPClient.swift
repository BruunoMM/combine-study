import Combine
import Foundation

enum NetworkError: Error {
    case invalidSearchTerm
    case badUrl
}

class HTTPClient {

    func searchMovies(with term: String) -> AnyPublisher<[Movie], Error> {
        guard let encodedSearch = term.urlEncoded else {
            return Fail(error: NetworkError.invalidSearchTerm).eraseToAnyPublisher()
        }

        guard let url = URL(string: "https://www.omdbapi.com/?s=\(encodedSearch)&page=1&apiKey=3273df37") else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map(\.search)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Error> in
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
