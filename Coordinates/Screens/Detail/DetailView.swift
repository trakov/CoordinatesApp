import SwiftUI

struct DetailView: View {
    @State var points: [Point]
    
    var body: some View {
        VStack {
            List {
                ForEach(points) { point in
                    HStack {
                        Text("\(point.x)")
                        Spacer()
                        Text("\(point.y)")
                    }
                }
            }
            ChartView(viewModel: ChartViewModel(points: points))
                .padding()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(points: [
            Point(x: -2.0, y: -2.0),
            Point(x: -1.0, y: 2.0),
            Point(x: 0.0, y: -3.0),
            Point(x: 1.0, y: 4.0),
            Point(x: 2.0, y: -2.0),
            Point(x: 3.0, y: 5.0),
            Point(x: 4.0, y: -3.0)
        ])
    }
}
