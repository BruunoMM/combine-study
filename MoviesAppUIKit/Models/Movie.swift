struct Movie: Decodable {
    let title: String
    let year: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
    }
}

struct SearchResponse: Decodable {
    let search: [Movie]

    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
}
