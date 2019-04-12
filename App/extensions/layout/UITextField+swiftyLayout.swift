import UIKit

class TextFieldDelegate : NSObject,UITextFieldDelegate {
    private let textField : UITextField
    var onNext : ((UITextField)->Void)? = nil
    var onSubmit : ((UITextField)->Void)? = nil
    var onChange : ((UITextField,String)->Void)? = nil
    
    init(textField : UITextField) {
        self.textField = textField
        super.init()
        self.textField._delegate = self
        self.textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onNext?(self.textField)
        self.onSubmit?(self.textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        self.onChange?(self.textField, newString)
        return true
    }
}

extension UITextField {
    
    @discardableResult func placeholder(_ placeholder : R.string, _ args : CVarArg...) -> UITextField {
        return self.placeholder(placeholder.string(args))
    }
    
    @discardableResult func placeholder(_ placeholder : String?) -> UITextField {
        self.placeholder = placeholder
        return self
    }
    
    @discardableResult func text(_ text : R.string, _ args : CVarArg...) -> UITextField {
        return self.text(text.string(args))
    }
    
    @discardableResult func text(_ text : String?) -> UITextField {
        self.text = text
        return self
    }
    
    @discardableResult func textAlignment(_ alignment : NSTextAlignment) -> UITextField {
        self.textAlignment = alignment
        return self
    }
    
    @discardableResult func keyboardType(_ type : UIKeyboardType) -> UITextField {
        self.keyboardType = type
        return self
    }
    
    @discardableResult func adjustFontSize(_ type : Bool) -> UITextField {
        self.adjustsFontSizeToFitWidth = type
        return self
    }
    
    @discardableResult func font(_ font : R.font) -> Self {
        self.font(font.font)
        return self
    }
    
    @discardableResult func font(_ font : UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult func textColor(_ color : R.color) -> Self {
        return self.textColor(color.color)
    }
    
    @discardableResult func textColor(_ color : UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult func tintColor(_ color : R.color) -> Self {
        self.tintColor(color.color)
        return self
    }
    
    @discardableResult func tintColor(_ color : UIColor) -> Self {
        self.tintColor = color
        return self
    }
    
    @discardableResult func keyboard(_ look : UIKeyboardAppearance = .dark,
                                     type: UIKeyboardType = .default,
                                     autocorrection: Bool = false,
                                     autocapitalization: Bool = false) -> UITextField {
        self.keyboardType = type
        self.keyboardAppearance = look
        self.autocorrectionType = autocorrection ? .yes : .no
        self.autocapitalizationType = autocapitalization ? .sentences : .none
        return self
    }
}

extension UITextField {
    
    @discardableResult
    func on(change : @escaping (UITextField,String)->Void) -> UITextField {
        self._delegate.onChange = change
        return self
    }
    
    @discardableResult
    func on(change : R.event) -> UITextField {
        self._delegate.onChange = { textField, text in
            textField.notify(event: change)
        }
        return self
    }
    
    @discardableResult
    func on(submit : R.event) -> UITextField {
        self._delegate.onSubmit = { textField in
            textField.notify(event: submit)
        }
        return self
    }
    
    
    
    @discardableResult
    func on(next : R.id) -> UITextField {
        
        self._delegate.onNext = { textField in
            textField.resignFirstResponder()
            var controller : UIViewController?
            var parentResponder: UIResponder? = textField
            while parentResponder != nil {
                parentResponder = parentResponder!.next
                if let viewController = parentResponder as? UIViewController {
                    controller = viewController
                    break;
                }
            }
            if let next = controller?.view.getView(next) {
                next.becomeFirstResponder()
                GestureTarget.existingTarget(inTargetView: next)?.containers.forEach({$0.closure()})
                if let n = next as? UIButton {
                    n.sendActions(for: .touchUpInside)
                }
            }
        }

        return self
    }
    
    private struct AssociatedKeys {
        static var _nextDelegate = "nextResponder"
    }
    
    var _delegate : TextFieldDelegate {
        get {
            if let d = objc_getAssociatedObject(self, &AssociatedKeys._nextDelegate) as? TextFieldDelegate {
                return d
            } else {
                self._delegate = TextFieldDelegate(textField: self)
                return self._delegate
            }
            
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys._nextDelegate,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
