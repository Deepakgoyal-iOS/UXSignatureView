//
//  UXSignatureComponentsView.swift
//  UXSignatureView
//
//  Created by Deepak Goyal on 12/03/24.
//

import UIKit

protocol UXSignatureComponentsViewDelegate: AnyObject{
    func didTapPicker()
    func didTapUndo()
    func didSelectEraser()
    func didSelectPen()
    func didTapCross()
}

class UXSignatureComponentsView: UIView{
    
    private(set) lazy var pickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .black
        if #available(iOS 14, *){
            button.setImage(.init(systemName: "pencil.tip.crop.circle"), for: .normal)
            button.isHidden = false
        }
        else{
            button.isHidden = true
        }
        button.addTarget(self, action: #selector(didTapPicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .systemBlue
        if #available(iOS 13, *){
            button.setImage(.init(systemName: "arrow.uturn.backward.circle"), for: .normal)
        }
        else{
            button.setImage(.init(named: "undo"), for: .normal)
        }
        button.addTarget(self, action: #selector(didTapUndo), for: .touchUpInside)
        return button
    }()
    
    private lazy var eraserButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.layer.borderWidth = 1.5
        button.backgroundColor = .clear
        button.setImage(.init(named: "eraser"), for: .normal)
        button.addTarget(self, action: #selector(didSelectEraser), for: .touchUpInside)
        return button
    }()
    
    private lazy var penButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.layer.borderWidth = 1.5
        button.backgroundColor = .clear
        button.setImage(.init(named: "pencil"), for: .normal)
        button.addTarget(self, action: #selector(didSelectPen), for: .touchUpInside)
        return button
    }()
    
    private lazy var crossButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .systemBlue
        if #available(iOS 13, *){
            button.setImage(.init(systemName: "xmark"), for: .normal)
        }
        else{
            button.setImage(.init(named: "cross"), for: .normal)
        }
        button.addTarget(self, action: #selector(didTapCross), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textColor = .black
        title.text = "Draw Sign"
        return title
    }()
    
    private lazy var buttonsHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        stack.spacing = 8
        stack.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private(set) lazy var typesHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .lightGray.withAlphaComponent(0.2)
        stack.layer.cornerRadius = 14
        stack.clipsToBounds = true
        stack.spacing = 8
        stack.layoutMargins = .init(top: 2, left: 2, bottom: 2, right: 2)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.isHidden = true
        return stack
    }()
    
    var delegate: UXSignatureComponentsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        layoutConstraints()
        pen(isSelected: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        self.addSubview(buttonsHStack)
        self.buttonsHStack.addArrangedSubview(titleLabel)
        self.buttonsHStack.addArrangedSubview(undoButton)
        self.buttonsHStack.addArrangedSubview(typesHStack)
        self.buttonsHStack.addArrangedSubview(pickerButton)
        self.buttonsHStack.addArrangedSubview(crossButton)
        self.typesHStack.addArrangedSubview(penButton)
        self.typesHStack.addArrangedSubview(eraserButton)
    }
    
    private func layoutConstraints(){
        
        NSLayoutConstraint(item: buttonsHStack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonsHStack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonsHStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonsHStack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        undoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        eraserButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        pickerButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        penButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        crossButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc private func didTapUndo(){
        delegate?.didTapUndo()
    }
    
    @objc private func didTapCross(){
        delegate?.didTapCross()
    }
    
    @objc private func didSelectEraser(){
        delegate?.didSelectEraser()
        pen(isSelected: false)
    }
    
    @objc private func didSelectPen(){
        delegate?.didSelectPen()
        pen(isSelected: true)
    }
    
    @objc private func didTapPicker(){
        delegate?.didTapPicker()
    }
    
    private func pen(isSelected: Bool){
        
        UIView.animate(withDuration: 0.2) {
            self.penButton.backgroundColor = isSelected ? .white : .clear
            self.penButton.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            self.eraserButton.backgroundColor = !isSelected ? .white : .clear
            self.eraserButton.layer.borderColor = !isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
        

    }
}
