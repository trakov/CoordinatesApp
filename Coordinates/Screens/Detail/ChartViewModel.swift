import Foundation

struct Line {
    let from: CGPoint
    let to: CGPoint
}

@MainActor class ChartViewModel: ObservableObject {
    @Published private(set) var cgPoints: [CGPoint] = []
    @Published private(set) var grid: [Line] = []
    @Published private(set) var axes: [Line] = []

    var viewSize: CGSize = .zero {
        didSet {
            update(with: CGSize(width: max(viewSize.width, 50), height: max(viewSize.height, 50)))
        }
    }
    private var area = (origin: (x: 0, y: 0), size: (width: 0, height: 0))
    private var step: CGFloat = 0
    
    private let points: [Point]
    private let leftBottom: Point
    private let rightTop: Point

    init(points: [Point]) {
        self.points = points
        var minY = CGFloat.infinity
        var maxY = -CGFloat.infinity
        for point in points {
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }
        leftBottom = Point(x: points.first!.x, y: minY)
        rightTop = Point(x: points.last!.x, y: maxY)
    }
    
    private func update(with viewSize: CGSize, margin: CGFloat = 2) {
        step = min(
            viewSize.height/(rightTop.y - leftBottom.y + margin),
            viewSize.width/(rightTop.x - leftBottom.x + margin)
        )
        area = (
            origin: (
                x: Int(rightTop.x + leftBottom.x - viewSize.width / step) / 2,
                y: Int(rightTop.y + leftBottom.y - viewSize.height / step) / 2
            ),
            size: (
                width: Int(viewSize.width / step),
                height: Int(viewSize.height / step)
            )
        )

        grid = (1...Int(area.size.width)).map { index in
            let x = CGFloat(index) * step
            return Line(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: viewSize.height))
        } + (1...Int(area.size.height)).map { index in
            let y = CGFloat(index) * step
            return Line(from: CGPoint(x: 0, y: y), to: CGPoint(x: viewSize.width, y: y))
        }

        axes = []
        if area.origin.x < 0 && area.origin.x + area.size.width > 0 {
            let x = CGFloat(-area.origin.x) * step
            axes.append(Line(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: viewSize.height)))
        }
        if area.origin.y < 0 && area.origin.y + area.size.height > 0 {
            let y = CGFloat(area.size.height + area.origin.y) * step
            axes.append(Line(from: CGPoint(x: 0, y: y), to: CGPoint(x: viewSize.width, y: y)))
        }
        cgPoints = points.map { point in
            let x = (point.x - CGFloat(area.origin.x)) * step
            let y = (CGFloat(area.size.height) - point.y + CGFloat(area.origin.y)) * step
            return CGPoint(x: x, y: y)
        }
    }
}
