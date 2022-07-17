//
//  ProductTableViewCell.swift
//  ProductCatalog
//
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    let productIdLabel = UILabel()
    let productInfoLabel = UILabel()
    let priceLabel = UILabel()
    let colorSizeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let stx = UIStackView(arrangedSubviews: [productIdLabel, priceLabel])
        stx.axis = .horizontal
        stx.distribution = .fill
        
        let stx1 = UIStackView(arrangedSubviews: [productInfoLabel, colorSizeLabel])
        stx1.axis = .vertical
        stx1.distribution = .fill
        
        let stx2 = UIStackView(arrangedSubviews: [stx, stx1])
        stx2.axis = .vertical
        stx2.setCustomSpacing(5, after: stx)
        stx2.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stx2)
        NSLayoutConstraint.activate([stx2.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Constants.ProductCataView.productCellInsets.left),
                                     stx2.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Constants.ProductCataView.productCellInsets.right),
                                     stx2.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.ProductCataView.productCellInsets.bottom),
                                     stx2.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.ProductCataView.productCellInsets.top)])
        
        self.productInfoLabel.font = Constants.ProductCataView.productInfoFont
        self.productIdLabel.font = Constants.ProductCataView.productIdFont
        self.priceLabel.font = Constants.ProductCataView.productPriceFont
        self.colorSizeLabel.font = Constants.ProductCataView.productInfoFont
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ProductTableViewCell {
    func configure(_ product: Product) {
        let list = "$" + String(format: "%.2f", Double(product.listPrice)/100.0)
        let sales = "$" + String(format: "%.2f", Double(product.salesPrice)/100.0)
        
        self.productIdLabel.text = "\(product.productId)"
        self.priceLabel.text = list + "/" + sales
        self.productInfoLabel.text = "\(product.title)"
        self.colorSizeLabel.text = "\(product.color), \(product.size)"
    }
}
