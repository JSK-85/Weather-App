import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create a new window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the root view controller to our main weather controller
        let weatherViewController = WeatherViewController()
        let navigationController = UINavigationController(rootViewController: weatherViewController)
        window?.rootViewController = navigationController
        
        // Make the window visible
        window?.makeKeyAndVisible()
        
        return true
    }
}