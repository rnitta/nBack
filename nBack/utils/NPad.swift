//
//  NPad.swift
//  nBack
//
//  Created by PT2051 on 2018/12/22.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit


public struct Item {
    public var backgroundColor: UIColor? = .white
    public var selectedBackgroundColor: UIColor? = .clear
    public var image: UIImage?
    public var title: String?
    public var titleColor: UIColor? = .black
    public var font: UIFont? = .systemFont(ofSize: 17)
    
    public init() {}
    public init(title: String?) {
        self.title = title
    }
    public init(image: UIImage?) {
        self.image = image
    }
}

public typealias Row = Int
public typealias Column = Int

// MARK: - Position
public typealias Position = (row: Row, column: Column)

// MARK: - NumPadDataSource
public protocol NumPadDataSource: class {
    
    /// The number of rows.
    func numberOfRowsInNumPad(_ numPad: NumPad) -> Int
    
    /// The number of columns.
    func numPad(_ numPad: NumPad, numberOfColumnsInRow row: Row) -> Int
    
    /// The item at position.
    func numPad(_ numPad: NumPad, itemAtPosition position: Position) -> Item
    
}

// MARK: - NumPadDelegate
public protocol NumPadDelegate: class {
    
    /// The item was tapped handler.
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position)
    
    /// The size of an item at position.
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize
    
}

public extension NumPadDelegate {
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {}
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize { return CGSize() }
}

// MARK: - NumPad
open class NumPad: UIView {
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
        self.addSubview(collectionView)
        collectionView.constrainToEdges()
        return collectionView
        }()
    
    /// Data source for the number pad.
    open weak var dataSource: NumPadDataSource?
    
    /// Delegate for the number pad.
    open weak var delegate: NumPadDelegate?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        _ = collectionView
    }
    
    open func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - UICollectionViewDataSource
extension NumPad: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfRows()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns(section: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let position = self.position(forIndexPath: indexPath)
        guard let item = dataSource?.numPad(self, itemAtPosition: position) else { return Cell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as! Cell
        cell.item = item
        cell.buttonTapped = { [unowned self] _ in
            self.delegate?.numPad(self, itemTapped: item, atPosition: position)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NumPad: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let position = self.position(forIndexPath: indexPath)
        let size = delegate?.numPad(self, sizeForItemAtPosition: position) ?? CGSize()
        return !size.isZero() ? size : {
            let indexPath = self.indexPath(for: position)
            var size = collectionView.bounds.size
            size.width /= CGFloat(numberOfColumns(section: indexPath.section))
            size.height /= CGFloat(numberOfRows())
            return size
            }()
    }
    
}

// MARK: -
public extension NumPad {
    
    /// Returns the item at the specified position.
    func item(for position: Position) -> Item? {
        let indexPath = self.indexPath(for: position)
        let cell = collectionView.cellForItem(at: indexPath)
        return (cell as? Cell)?.item
    }
    
}

// MARK: -
private extension NumPad {
    
    /// Returns the index path at the specified position.
    func indexPath(for position: Position) -> IndexPath {
        return IndexPath(item: position.column, section: position.row)
    }
    
    /// Returns the position at the specified index path.
    func position(forIndexPath indexPath: IndexPath) -> Position {
        return Position(row: indexPath.section, column: indexPath.item)
    }
    
    func numberOfRows() -> Int {
        return dataSource?.numberOfRowsInNumPad(self) ?? 0
    }
    
    func numberOfColumns(section: Int) -> Int {
        return dataSource?.numPad(self, numberOfColumnsInRow: section) ?? 0
    }
    
}

extension UIView {
    
    @discardableResult
    func constrainToEdges(_ inset: UIEdgeInsets = UIEdgeInsets()) -> [NSLayoutConstraint] {
        return constrain {[
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: inset.left),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: inset.bottom),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: inset.right)
            ]}
    }
    
    @discardableResult
    func constrain(constraints: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        let constraints = constraints(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
}

extension CGSize {
    
    func isZero() -> Bool {
        return self.equalTo(CGSize())
    }
    
}

extension UIImage {
    
    convenience init(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: CGPoint(), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
    
}

extension UIButton {
    
    var title: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
    
    var titleColor: UIColor? {
        get { return titleColor(for: .normal) }
        set { setTitleColor(newValue, for: .normal) }
    }
    
    var image: UIImage? {
        get { return image(for: .normal) }
        set { setImage(newValue, for: .normal) }
    }
    
    var backgroundImage: UIImage? {
        get { return backgroundImage(for: .normal) }
        set { setBackgroundImage(newValue, for: .normal) }
    }
    
}

class Cell: UICollectionViewCell {
    
    lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
        self.contentView.addSubview(button)
        let edges = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 0)
        button.constrainToEdges(edges)
        return button
        }()
    
    var item: Item! {
        didSet {
            button.title = item.title
            button.titleColor = item.titleColor
            button.titleLabel?.font = item.font
            button.image = item.image
            button.tintColor = item.titleColor
            var image = item.backgroundColor.map { UIImage(color: $0) }
            button.backgroundImage = image
            image = item.selectedBackgroundColor.map { UIImage(color: $0) }
            button.setBackgroundImage(image, for: .highlighted)
            button.setBackgroundImage(image, for: .selected)
        }
    }
    
    var buttonTapped: ((UIButton) -> Void)?
    
    @IBAction func _buttonTapped(_ button: UIButton) {
        buttonTapped?(button)
    }
    
}
