//
//  UXSignatureInfoView.swift
//  UXSignatureView
//
//  Created by Deepak Goyal on 13/03/24.
//

import UIKit

class UXSignatureInfoView: UIView{
    
    private(set) lazy var detailButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray
        button.setTitle("", for: .normal)
        return button
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 14, weight: .regular)
        title.textColor = .gray
        title.numberOfLines = 0
        return title
    }()
    
    private(set) lazy var detailButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var tint: UIColor = .gray{
        didSet{
            detailButton.tintColor = tint
        }
    }
    
    var attributedText: NSAttributedString?{
        didSet{
            detailLabel.attributedText = attributedText
        }
    }
    
    var text: String?{
        didSet{
            detailLabel.text = text
        }
    }
    
    private lazy var contentHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        stack.spacing = 4
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        layoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        self.addSubview(contentHStack)
        detailButtonContainer.addSubview(detailButton)
        self.contentHStack.addArrangedSubview(detailButtonContainer)
        self.contentHStack.addArrangedSubview(detailLabel)
    }
    
    private func layoutConstraints(){
        
        NSLayoutConstraint(item: contentHStack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentHStack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentHStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentHStack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        detailButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        detailButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        NSLayoutConstraint(item: detailButton, attribute: .leading, relatedBy: .equal, toItem: self.detailButtonContainer, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailButton, attribute: .trailing, relatedBy: .equal, toItem: self.detailButtonContainer, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailButton, attribute: .top, relatedBy: .equal, toItem: self.detailButtonContainer, attribute: .top, multiplier: 1, constant: 0).isActive = true
        detailButtonContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
    }
}
