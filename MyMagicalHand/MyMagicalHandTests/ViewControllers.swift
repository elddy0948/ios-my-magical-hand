import UIKit
@testable import MyMagicalHand

func bringRootViewController() -> CanvasViewController {
    let window = UIApplication.shared.windows[0]
    return window.rootViewController as! CanvasViewController
}
