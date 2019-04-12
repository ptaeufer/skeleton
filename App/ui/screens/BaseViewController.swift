
import UIKit

class BaseViewController: UIViewController, EventListener {

    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.controllerView = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardAppearance()

    }
    
    func on(event: R.event) {
        switch event {
        default: break
        }
    }
    

    private func registerKeyboardAppearance() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.on(event: R.event.keyboardWillShow(keyboardSize.cgRectValue as CGRect))
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.on(event: R.event.keyboardWillHide(keyboardSize.cgRectValue as CGRect))
            }
        }
    }

}
