import PinataUI
import SwiftUI

enum Screen: Hashable {
  case wallet, preview
  case fullShopping(detailsId: String?, detailsType: String?)

  var title: String {
    switch self {
    case .wallet: return "Wallet"
    case .preview: return "Preview"
    case .fullShopping: return "Full Shopping"
    }
  }
}

/// One screen per component, picked from the menu. Wallet and Preview send a
/// `MarketplaceOpenEvent` when the renter wants the marketplace, and the app opens Full Shopping,
/// on the clicked item when the event carries one. Back returns to the previous screen.
struct MainView: View {
  @EnvironmentObject private var session: Session
  @State private var root: Screen = .wallet
  @State private var path: [Screen] = []
  @State private var toast: String?

  var body: some View {
    NavigationStack(path: $path) {
      screen(root)
        .id(root)  // the SDK views are single-use: every screen change creates a new one
        .navigationTitle(root.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Menu {
              Button("Wallet") { root = .wallet }
              Button("Preview") { root = .preview }
              Button("Full Shopping") { root = .fullShopping(detailsId: nil, detailsType: nil) }
              Divider()
              Button("Logout", role: .destructive) { session.logout() }
            } label: {
              Image(systemName: "line.3.horizontal")
            }
          }
        }
        .navigationDestination(for: Screen.self) { destination in
          screen(destination).navigationTitle(destination.title)
        }
    }
    .overlay(alignment: .bottom) {
      if let toast {
        Text(toast)
          .font(.footnote)
          .padding(12)
          .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
          .padding()
          .task(id: toast) {
            // A newer toast cancels this task; only an elapsed timer clears the overlay.
            guard (try? await Task.sleep(for: .seconds(3))) != nil else { return }
            self.toast = nil
          }
      }
    }
  }

  @ViewBuilder
  private func screen(_ screen: Screen) -> some View {
    switch screen {
    case .wallet:
      PinataComponent { configured(PinataMarketplaceWalletView()) }
    case .preview:
      PinataComponent { configured(PinataMarketplacePreviewView()) }
    case .fullShopping(let detailsId, let detailsType):
      PinataComponent {
        let view = PinataFullShoppingView()
        view.detailsId = detailsId
        view.detailsType = detailsType
        return configured(view)
      }
    }
  }

  private func configured(_ view: PinataComponentView) -> PinataComponentView {
    view.environment = .sandbox
    view.userToken = session.userToken
    view.onMarketplaceOpen = { event in
      path.append(.fullShopping(detailsId: event.detailsId, detailsType: event.detailsType))
    }
    view.onError = { message in toast = "Pinata error: \(message)" }
    return view
  }
}

/// The SDK views are plain UIViews; this is all SwiftUI needs.
struct PinataComponent: UIViewRepresentable {
  let make: () -> PinataComponentView

  func makeUIView(context: Context) -> PinataComponentView {
    let view = make()
    view.load()
    return view
  }

  func updateUIView(_ uiView: PinataComponentView, context: Context) {}
}
