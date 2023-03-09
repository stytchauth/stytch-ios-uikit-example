import UIKit
import StytchCore

final class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        StytchClient.configure(publicToken: <#YOUR TOKEN#>)
        logOut()
    }

    override func addChild(_ controller: UIViewController) {
        super.addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
    }

    func logOut() {
        removeChildren()
        addChild(AuthHomeViewController())
    }

    func logIn(response: AuthenticateResponseType) {
        removeChildren()
        let controller = AuthenticatedViewController()
        controller.configure(authResponse: response)
        addChild(controller)
    }

    private func removeChildren() {
        children.forEach {
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        }
    }
}
