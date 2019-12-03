
/*
 #if canImport(SwiftUI) && DEBUG
 import SwiftUI

 struct Preview_Previews: PreviewProvider {
     static var previews: some View {
         var preview = Layout.Preview()
         return preview.with(layout: <#layout#>, <#params#>).edgesIgnoringSafeArea(.all)
    
     }
 }
 #endif
 

 #if canImport(SwiftUI) && DEBUG
 import SwiftUI

 struct Preview_Previews: PreviewProvider {
     static var previews: some View {
         var preview = Layout.ControllerPreview()
         return preview.with(layout: PaypalSelectedSuccessLayout(), (title : "Hello", message : "was geht ab", buttonTitle : "digga")).edgesIgnoringSafeArea(.all)
    
     }
 }
 #endif
 
 */

import UIKit
import SwiftUI

extension Layout {
    
    struct Preview : UIViewRepresentable {
        typealias UIViewType = UIView
        var controller : UIViewController? = nil
        
        
        mutating func with(layout : Layout) -> Preview {
            self.controller = UIViewController(nibName: nil, bundle: nil).apply {
                $0.view.inflate(layout)
            }
            return self
        }
        
        mutating func with<T>(layout : Layout, params : T) -> Preview {
            self.controller =  UIViewController(nibName: nil, bundle: nil).apply {
                $0.view.inflate(layout, params)
            }
            return self
        }
        
        func makeUIView(context: UIViewRepresentableContext<Layout.Preview>) -> UIView {
            return self.controller?.view ?? makeUIView(context: context)
        }
        
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Layout.Preview>) {}
        
        
    }
    
}
