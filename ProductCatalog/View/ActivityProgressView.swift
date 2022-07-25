//
//  ActivityProgressView.swift
//  ProductCatalog
//
//

import UIKit

class ActivityProgressView: UIStackView {
    weak var titleLabel: UILabel!
    weak var progressControl: UIProgressView!
    weak var messageLabel: UILabel!
    weak var activity: UIActivityIndicatorView!
    
    static func createProgressView(in superView: UIView, _ titleText: String? = nil) -> ActivityProgressView {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.bold)
        titleLabel.text = titleText == nil ? Constants.ImportDatabase.title : titleText!
        
        let progressControl = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
        
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.light)
        
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
        let stx = ActivityProgressView(arrangedSubviews: [titleLabel, progressControl, messageLabel, activityView])
        
        stx.translatesAutoresizingMaskIntoConstraints = false
        stx.progressControl = progressControl
        stx.messageLabel = messageLabel
        stx.activity = activityView
        
        stx.axis = .vertical
        stx.distribution = .fillProportionally
        superView.addSubview(stx)
        NSLayoutConstraint.activate([stx.bottomAnchor.constraint(equalTo: superView.centerYAnchor, constant: 0),
                                     stx.heightAnchor.constraint(equalToConstant: 120),
                                     stx.widthAnchor.constraint(greaterThanOrEqualToConstant: 200.0),
                                     stx.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: 0)])
        activityView.startAnimating()
        
        return stx
    }

    func updateStatus(_ progress: Float, _ message: String) {
        progressControl.setProgress(progress, animated: false)
        messageLabel.text = message
        activity.stopAnimating()
    }
}
