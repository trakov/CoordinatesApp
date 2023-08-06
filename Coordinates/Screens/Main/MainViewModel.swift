import SwiftUI

extension MainView {
    @MainActor class ViewModel: ObservableObject {
        @Published var countString = ""
        @Published var isShowingDetailView = false
        @Published var isLoading = false

        var points: [Point] = []
        var error: RequestError?
        
        private let pointsService: IPointsService
        
        init(pointsService: IPointsService) {
            self.pointsService = pointsService
        }
        
        func getPoints() {
            guard let count = Int(countString) else {
                return
            }
            isLoading = true
            pointsService.getPoints(count: count) { result in
                switch result {
                case .success(let points):
                    self.points = points.points.sorted {
                        $0.x == $1.x ? $0.y <= $1.y : $0.x <= $1.x
                    }
                    self.isShowingDetailView = true
                case .failure(let error):
                    self.error = error
                }
                self.isLoading = false
            }
        }
    }
}
