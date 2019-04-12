import UIKit

extension UITableView {
    
    @discardableResult
    func separator(_ style : UITableViewCell.SeparatorStyle) -> UITableView {
        self.separatorStyle = style
        return self
    }
    
    @discardableResult
    func header(_ view : UIView) -> UITableView {
        self.tableHeaderView = view
        return self
    }
    
}
