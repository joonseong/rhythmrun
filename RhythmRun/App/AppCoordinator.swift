import SwiftUI

enum AppRoute {
    case onboarding
    case auth
    case home
}

struct AppCoordinator: View {
    @State private var route: AppRoute = .onboarding

    var body: some View {
        switch route {
        case .onboarding:
            OnboardingView(onComplete: { route = .auth })
        case .auth:
            AuthView(onLogin: { route = .home })
        case .home:
            HomeView()
        }
    }
}
