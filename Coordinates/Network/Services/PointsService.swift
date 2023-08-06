protocol IPointsService: AnyObject {
    func getPoints(count: Int, completion: ((Result<Points, RequestError>) -> Void)?)
}

final class PointsService: IPointsService, HTTPClient {
    func getPoints(count: Int, completion: ((Result<Points, RequestError>) -> Void)?) {
        sendRequest(
            endpoint: PointsEndpoint.getPoints(count: count),
            responseModel: Points.self) { result in
                switch result {
                case .success(let points):
                    completion?(.success(points))
                case .failure(let error):
                    completion?(.failure(error))
                    print(error)
                }
            }
    }
}
