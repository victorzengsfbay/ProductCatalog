//
//  TableSectionHeader.swift
//  ProductCatalog
//
//

import UIKit

class TableSectionHeader: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.tertiarySystemBackground
        let lb1 = UILabel()
        lb1.text = "Product"
        lb1.font = Constants.ProductCataView.homeTableViewSectionHeaderFont
        lb1.textColor = UIColor.secondaryLabel
        let lb2 = UILabel()
        lb2.text = "Price(List/Sales)"
        lb2.font = Constants.ProductCataView.homeTableViewSectionHeaderFont
        lb2.textColor = UIColor.secondaryLabel
        let stx = UIStackView(arrangedSubviews: [lb1, lb2])
        stx.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stx)
        NSLayoutConstraint.activate([stx.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.ProductCataView.productCellInsets.left),
                                     stx.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Constants.ProductCataView.productCellInsets.right),
                                     stx.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
