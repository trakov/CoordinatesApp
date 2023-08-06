import SwiftUI

struct ChartView: View {
    @StateObject var viewModel: ChartViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GridView(viewModel: viewModel)
                GraphView(viewModel: viewModel, lineRadius: 0.0)
            }
            .onChange(of: geo.size) { size in
                viewModel.viewSize = size
            }
            .onAppear {
                viewModel.viewSize = geo.size
            }
        }
    }
}

private struct GridView: View {
    @StateObject var viewModel: ChartViewModel

    var body: some View {
        ZStack {
            Path { path in
                for line in viewModel.grid {
                    path.move(to: line.from)
                    path.addLine(to: line.to)
                }
            }
            .stroke(.gray)
            Path { path in
                for line in viewModel.axes {
                    path.move(to: line.from)
                    path.addLine(to: line.to)
                }
            }
            .stroke(.black)
        }
    }
}

private struct GraphView: View {
    @StateObject var viewModel: ChartViewModel

    let lineRadius: CGFloat

    var body: some View {
        Path { path in
            for (i, point) in viewModel.cgPoints.enumerated() {
                guard i > 0 else {
                    path.move(to: point)
                    continue
                }
                let prevPoint = viewModel.cgPoints[i - 1]
                let xOffset = (point.x - prevPoint.x) * lineRadius
                path.addCurve(
                    to: point,
                    control1: CGPoint(x: prevPoint.x + xOffset, y: prevPoint.y),
                    control2: CGPoint(x: point.x - xOffset, y: point.y)
                )
            }
        }
        .stroke(
            .blue,
            style: StrokeStyle(lineWidth: 3)
        )
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(viewModel: ChartViewModel(points: [
            Point(x: 12.23, y: 30.33),
            Point(x: -12.23, y: 50.33),
            Point(x: -32.23, y: -30.33)
        ]))
    }
}
