import UIKit


class Adapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var list : UITableView? = nil
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func setList( _ list : UITableView) { self.list = list; self.reload() }
    
    func reload() { self.list?.reloadData() }
    func add<T>(_ item : T) {}
    func remove<T>(_ item : T) {}
    func update<T>(_ item : T) {}
    func update<T>(_ item : T, at index: Int) {}
    func set<T>(_ items : [T]) {}
}

class ListAdapter<D:Identifiable> : Adapter  {
    
    private var data : [D] = []
    private let layout : Layout?
    private let emptyLayout : Layout?
    private var emptyView : UIView? = nil
    
    var dataSet : [D] {
        return self.data
    }
    
    init(_ data : [D], _ layout : Layout?, _ emptyState : Layout? = nil) {
        self.data = data
        self.layout = layout
        self.emptyLayout = emptyState
    }
    
    override func reload() {
        super.reload()
        if self.data.isEmpty, emptyLayout != nil {

            after(0.1) {
                if self.data.isEmpty, let l = self.emptyLayout, self.emptyView == nil {
                    
                    self.list!.layoutIfNeeded()
                    let size = self.list!.frame.size
                    
                    self.emptyView = UIView(layout: l)
                        .width(size.width)
                        .height(size.height)
                        .leading(0)
                        .trailing(0)
                        .bottom(0)
                        .top(0)
                        .alpha(0)
                    self.list?.backgroundView = self.emptyView!
                    self.emptyView?.refreshConstraints()
                }
                self.emptyView?.animate().alpha(1).start()
            }

        } else {
            emptyView?.alpha(0)
        }
    }
    
    override func set<T>(_ items: [T]) {
        if let _items = items as? [D] {
            self.data = _items
            self.reload()
        }
    }
    
    override func add<T>(_ item: T) {
        if let _item = item as? D {
            if let existing = self.data.filter({ $0.id == _item.id}).first { self.remove(existing) }
            let isEmpty = self.data.isEmpty
            self.data.insert(_item, at : 0)
            if isEmpty { return reload() }
            self.list?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    override func remove<T>(_ item: T) {
        if let _item = item as? D, let index = self.data.index(where: { $0.id == _item.id}) {
            self.data = self.data.filter({ $0.id != _item.id})
            if self.data.isEmpty { return reload() }
            self.list?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    override func update<T>(_ item: T) {
        if let _item = item as? D, let index = self.data.index(where: { $0.id == _item.id}) {
            self.update(item, at: index)
        } else {
            self.add(item)
        }
       
    }
    
    override func update<T>(_ item : T, at index: Int) {
        if let _item = item as? D, index < self.data.count {
            self.data.remove(at: index)
            self.data.insert(_item, at : index)
            UIView.performWithoutAnimation {
                self.list?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if !data.isEmpty, let l = layout {
            cell.contentView.inflate(l, data[indexPath.row])
        }
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.data.count {
            tableView.notify(event: R.event.selected(self.data[indexPath.row] as Any))
        }
    }
    
}

