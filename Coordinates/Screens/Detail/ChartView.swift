import SwiftUI

struct ChartView: View {
    @StateObject var viewModel: ChartViewModel
    
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    private let minScale = 1.0
    private let maxScale = 3.0
    
    @State private var width: CGFloat = 150
    @State private var height: CGFloat = 150
    @State private var position: CGSize = .zero
    @State private var lastPosition: CGSize = .zero

    private var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                scale *= delta
                lastScale = value
            }
            .onEnded { value in
                withAnimation {
                    scale = max(scale, minScale)
                    scale = min(scale, maxScale)
                }
                lastScale = 1.0
            }
    }
    
    private var drag: some Gesture {
        DragGesture()
            .onChanged { state in
                let size = state.translation
                let delta = CGSize(
                    width: lastPosition.width - size.width,
                    height: lastPosition.height - size.height
                )
                position = CGSize(
                    width: position.width - delta.width,
                    height: position.height - delta.height
                )
                lastPosition = size
            }
            .onEnded { state in
                lastPosition = .zero
            }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                GridView(viewModel: viewModel)
                GraphView(viewModel: viewModel, lineRadius: 1.0)
            }
            .onChange(of: geo.size) { size in
                viewModel.viewSize = size
            }
            .onAppear {
                viewModel.viewSize = geo.size
            }
//            .onLongPressGesture {
//                // doesn't work, empty image
//                UIImageWriteToSavedPhotosAlbum(snapshot(), nil, nil, nil)
//            }
        }
        .scaleEffect(scale)
        .offset(position)
        .gesture(drag)
        .gesture(magnification)
        .onTapGesture {
            withAnimation {
                position = .zero
                scale = 1.0
            }
        }
        .clipped()
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
            .stroke(.red)
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
            Point(x: -2.0, y: -2.0),
            Point(x: -1.0, y: 2.0),
            Point(x: 0.0, y: -3.0),
            Point(x: 1.0, y: 4.0),
            Point(x: 2.0, y: -2.0),
            Point(x: 3.0, y: 5.0),
            Point(x: 4.0, y: -3.0)
        ]))
    }
}
