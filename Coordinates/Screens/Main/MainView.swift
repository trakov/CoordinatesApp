import SwiftUI

struct MainView: View {
    @StateObject var viewModel = ViewModel(pointsService: PointsService())
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: DetailView(points: viewModel.points),
                    isActive: $viewModel.isShowingDetailView
                ) {
                    EmptyView()
                }
                if viewModel.isLoading {
                    EmptyView()
                } else {
                    Text("Type the count of coordinates")
                    TextField("count", text: $viewModel.countString)
                        .border(.black)
                        .padding()
                    Button("GO!") {
                        viewModel.getPoints()
                    }
                }
            }
            .padding()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
