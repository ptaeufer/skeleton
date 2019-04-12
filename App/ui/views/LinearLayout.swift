import UIKit

enum Orientation {
    case vertical, horizontal
}

class LinearLayout : UIScrollView {
    
    var stored : Any? = nil
    let orientation : Orientation
    private let padding : UIEdgeInsets
    private let content = UIView()
    private var overflowEnabled : Bool = false
    var contentView : UIView {
        return content
    }
    @discardableResult func overflow(_ val : Bool) -> Self {
        self.overflowEnabled = val
        return self
    }
    
    init(_ orientation : Orientation = .horizontal, padding : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        self.orientation = orientation
        self.padding = padding
        super.init(frame: .zero)
        super.addSubview(content.leading(0).trailing(0).bottom(0).top(0))
        switch orientation {
        case .vertical: content.width(0.99, to: self.id)
        case .horizontal: content.height(0.99, to: self.id)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
        if view is UIImageView {
            super.addSubview(view)
        } else {
            content.addSubview(view)
            refresh()
        }
    }
    override func willRemoveSubview(_ subview: UIView) { refresh() }
    
    private func refresh() {
        switch orientation {
        case .vertical: alignVertical()
        case .horizontal: alignHorizontal()
        }
    }
    
    override func removeAllSubviews() {
        content.removeAllSubviews()
    }
    
    private func alignHorizontal() {
        content.subviews.forEach { $0.removeConstraint(.leading, .trailing) }
        var last : UIView?
        content.subviews.forEach { view in
            if view == content.subviews.first { view.leading(padding.left) }
            if view == content.subviews.last { view.trailing(padding.right) }
            if let l = last { view.leading(padding.left, to: l) }
            if view.constraint(.top) == nil && view.constraint(.height) == nil { view.top(0) }
            if view.constraint(.bottom) == nil && view.constraint(.height) == nil { view.bottom(0) }
            view.refreshConstraints()
            last = view
        }
    }
    
    private func alignVertical() {
        content.subviews.forEach { $0.removeConstraint(.top, .bottom) }
        var last : UIView?
        content.subviews.forEach { view in
            if view == content.subviews.first { view.top(padding.top) }
            if view == content.subviews.last { view.bottom(padding.bottom) }
            if let l = last { view.top(padding.top, to: l) }
            if view.constraint(.leading) == nil && view.constraint(.width) == nil { view.leading(0) }
            if view.constraint(.trailing) == nil && view.constraint(.width) == nil { view.trailing(0) }
            view.refreshConstraints()
            last = view
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.overflowEnabled {
            let parentLocation = self.convert(point, to: self.superview)
            var responseRect = self.frame
            responseRect.origin.x = 0
            responseRect.size.width = self.superview!.frame.size.width
            return responseRect.contains(parentLocation)
        }
        return super.point(inside: point, with: event)
    }
    
}
