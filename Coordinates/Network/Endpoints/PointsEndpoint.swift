private extension PointsEndpoint {
    struct Constants {
        static let points = "/points"
    }
}

enum PointsEndpoint {
    case getPoints(count: Int)
}

extension PointsEndpoint: Endpoint {

    var path: String {
        switch self {
        case .getPoints:
            return Constants.points
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getPoints:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .getPoints(let count):
            return .requestParameters(
                bodyEncoding: .url(parameters: ["count": count])
            )
        }
    }
}
