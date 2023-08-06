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
            Point(x: 12.23, y: 30.33),
            Point(x: -12.23, y: 50.33),
            Point(x: -32.23, y: -30.33)
        ])
    }
}
