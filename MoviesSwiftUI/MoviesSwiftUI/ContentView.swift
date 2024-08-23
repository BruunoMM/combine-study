import SwiftUI
import Combine

struct ContentView: View {
    @State private var viewModel: MovieListViewModel
    @State private var searchText: String

    init(viewModel: MovieListViewModel, searchText: String = "") {
        self.viewModel = viewModel
        self.searchText = searchText
    }

    var body: some View {
        VStack(spacing: 10){
            Text("Showing results for \"\(viewModel.searchSubject.value)\"")
                .font(.footnote)
                .opacity(viewModel.searchSubject.value.isEmpty ? 0 : 1)
            List($viewModel.movies) { movie in
                MovieView(movie: movie.wrappedValue)
            }.overlay(Group {
                if viewModel.movies.isEmpty && searchText.isEmpty {
                    Text("Search for a movie 🔎")
                } else if viewModel.movies.isEmpty && viewModel.loadingCompleted {
                    Text("Nothing found for \"\(searchText)\" 😿")
                }
            })
            .searchable(text: $searchText)
            .onChange(of: searchText) {
                viewModel.setSearchText(searchText)
            }
        }
    }
}

private struct MovieView: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: movie.poster) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    .frame(width: 75, height: 75)
                    .foregroundColor(Color.gray)
                    ProgressView()
                }

            }
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.year)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView(viewModel: MovieListViewModel(
            movies: [Movie(
                title: "Batman",
                year: "2022",
                imdbId: "123",
                poster: URL(string: "www.google.com"))],
            httpClient: HTTPClient())
        )
    }
}
