import Combine
import Foundation

class MovieListViewModel {
    @Published private(set) var movies: [Movie]
    @Published private(set) var loadingCompleted: Bool = false
    
    private let httpClient: HTTPClient
    private var subscriptions: Set<AnyCancellable> = []

    private var searchSubject = CurrentValueSubject<String, Never>("")

    init(movies: [Movie] = [], httpClient: HTTPClient = HTTPClient()) {
        self.movies = movies
        self.httpClient = httpClient
        setupSearchSubject()
    }

    private func setupSearchSubject() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.searchMovies(with: text)
            }.store(in: &subscriptions)
    }

    func setSearchText(_ text: String) {
        searchSubject.send(text)
    }

    func searchMovies(with term: String) {
        print("Searching on the network...")
        httpClient.searchMovies(with: term)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("Movies fetched.")
                case .failure(let error):
                    print("Search failed with error: \(error)")
                }
                self?.loadingCompleted = true
            } receiveValue: { movies in
                self.movies = movies
            }
            .store(in: &subscriptions)
    }
}
