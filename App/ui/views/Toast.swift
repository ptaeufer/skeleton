import UIKit

class Toast : UIView {
    
    private lazy var textLabel : UILabel! = getView(R.id.text)
    private lazy var action : UIButton! = getView(R.id.action)
    
    private var context : UIView? = nil
    private var message : String? = nil
    private var isVisible : Bool = false
    private var duration : Double = 4
    
    init() {
        super.init(frame : .zero)
        self.inflate(R.layout.toastLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func make(_ message : R.string, context : UIView?, callback : (()->Void)? = nil) {
        self.make(message.string(), context: context, callback: callback)
    }

    static func make(_ message : String, context : UIView?, callback : (()->Void)? = nil) {
        Toast()
            .message(message)
            .context(context)
            .show(callback)
    }
    
    static func build() -> Toast {
        return Toast()
    }
    
    func context(_ context : UIView?) -> Toast {
        self.context = context
        return self
    }
    
    func message(_ message : R.string) -> Toast {
        return self.message(message.string())
    }

    func message(_ message : String) -> Toast {
        self.message = message
        return self
    }
    
    func action(_ message : R.string, _ callback : @escaping ()->Void) -> Toast {
        return self.action(message.string().uppercased(), callback)
    }
    
    func action(_ message : String, _ callback : @escaping ()->Void) -> Toast {
        self.action.alpha = 1
        self.action.text(message.uppercased())
        self.action.on { _ in
            self.dismiss()
            callback()
        }
        return self
    }
    
    func actionColor(_ color : R.color) -> Toast {
        self.action.textColor(color)
        return self
    }
    
    
    func show(_ callback : (()->Void)? = nil) {
    
        guard let message = self.message, let context = self.context else {
            print("TOAST : Please provide message and context")
            return
        }
        
        self.textLabel.text = message
        self.bottom(-context.frame.size.height / 2)
            .leading(0)
            .trailing(0)
        context.addSubview(self)
        self.frame = CGRect(x: 0, y: 1000, width: context.frame.size.width, height: 50)
        self.refreshConstraints()
        self.layoutIfNeeded()
        self.constraint(.bottom)?.update(0, 0.4) { _ in
            after(self.duration) {
                if self.superview != nil {
                    self.dismiss(callback)
                }
            }
        }
        
    }
    
    func dismiss(_ callback : (()->Void)? = nil) {
        guard let context = self.context else {
            print("TOAST : Please provide context")
            return
        }
        self.constraint(.bottom)?.update(-context.frame.size.height / 2, 0.4) { _ in
            self.removeFromSuperview()
            callback?()
        }
    }
    
}

class ToastLayout : Layout {

    override func layout() -> [AnyObject] {
        return [
            UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                .bottom(0)
                .leading(0)
                .trailing(0)
                .top(0),
            
            UILabel()
                .id(R.id.text)
                .leading(20)
                .trailing(10, to : R.id.action)
                .bottom(20)
                .top(20)
                .textAlignment(.center)
                .textColor(.primary)
                .numberOfLines(0)
                .clipsToBounds(true)
                .font(R.font.primary.size(16)),
            
            UIButton()
                .id(R.id.action)
                .centerY(0)
                .trailing(20)
                .style(R.style.default)
                .alpha(0)
        ]
    }

}
