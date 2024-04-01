//
//  UXSignatureViewController.swift
//  UXSignatureView
//
//  Created by Deepak Goyal on 11/03/24.
//

import UIKit

protocol UXSignatureViewControllerDelegate: AnyObject{
    func didTapCapture(onViewController controller: UIViewController, image: UIImage)
    func didTapCross(onViewController controller: UIViewController)
    func didBeginSigning()
    func didEndSigning()
}
extension UXSignatureViewControllerDelegate{
    func didBeginSigning(){ }
    func didEndSigning(){ }
}

class UXSignatureViewController: UIViewController{
    
    enum CanvasSize{
        case fixed(width:CGFloat, height:CGFloat)
        case fixedWidth(_ width:CGFloat)
        case fixedHeight(_ height:CGFloat)
        case fill
    }
    
    private let F2F2F2_alpha1 = UIColor(red: 242/255.0, green: 242/255.0, blue: 246/255.0, alpha: 1.0)
    private let D5E6FD_alpha1 = UIColor(red: 213/255.0, green: 230/255.0, blue: 253/255.0, alpha: 1.0)
    
    private lazy var signatureComponentsView: UXSignatureComponentsView = {
        let view = UXSignatureComponentsView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.pickerButton.tintColor = penColor
        view.typesHStack.isHidden = watermark != nil
        return view
    }()
    
    private lazy var contentVStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fill
        return view
    }()
    
    private lazy var canvasContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var drawingView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = canvasBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var watermarkContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.axis = .vertical
        view.spacing = 8
        view.isHidden = true
        return view
    }()
    
    private lazy var watermarkImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = watermarkTint
        view.backgroundColor = .clear
        return view
    }()

    private lazy var canvas: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var detailView: UXSignatureInfoView = {
        let view = UXSignatureInfoView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = D5E6FD_alpha1
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        return button
    }()
    
    private lazy var signBezierPath: UIBezierPath = {
        let path = UIBezierPath()
        return path
    }()

    private lazy var canvasLayer: CAShapeLayer = {
        let signLayer = CAShapeLayer()
        signLayer.path = signBezierPath.cgPath
        signLayer.fillColor = UIColor.clear.cgColor
        signLayer.strokeColor = penColor.cgColor
        signLayer.lineWidth = penNibWidth
        return signLayer
    }()
    
    private var isPenEnabled: Bool = true{
        didSet{
            signatureComponentsView.pickerButton.alpha = isPenEnabled ? 1.0 : 0.5
            signatureComponentsView.pickerButton.isEnabled = isPenEnabled
            canvas.image = canvas.asImage
            clearDrawing()
            resetLayer(isEraser: !isPenEnabled)
        }
    }
    
    private var isParentNavigationBarHidden = false
    
    //MARK: Key Features
    
    weak var delegate: UXSignatureViewControllerDelegate?
    
    /// Set pen nib size/width you need to draw sign with (Line Width).
    var penNibWidth: CGFloat = 2.0{
        didSet{
            canvasLayer.lineWidth = penNibWidth
        }
    }
    
    /// Eraser width
    var eraserLineWidth: CGFloat = 30.0
    
    /// Set pen/line color you need to draw sign with (Line Color).
    var penColor: UIColor = .black{
        didSet{
            canvasLayer.strokeColor = penColor.cgColor
            signatureComponentsView.pickerButton.tintColor = penColor
        }
    }
    
    /// Set background color of signature
    var canvasBackgroundColor: UIColor = .white{
        didSet{
            canvas.backgroundColor = canvasBackgroundColor
        }
    }
    
    /// Set button text for capturing / saving signature image
    var captureButtonTitle: String = "Capture"{
        didSet{
            doneButton.setTitle(captureButtonTitle, for: .normal)
        }
    }
    
    /// Set signature heading
    var sheetTitle: String = "Draw Sign"{
        didSet{
            signatureComponentsView.titleLabel.text = sheetTitle
        }
    }
    
    /// Set signature heading in attributed format(Optional)
    var attributedSheetTitle: NSAttributedString?{
        didSet{
            signatureComponentsView.titleLabel.attributedText = attributedSheetTitle
        }
    }
    
    /// Set Information text(Optional)
    var infoTitle: String?{
        didSet{
            detailView.text = infoTitle
            detailView.isHidden = (infoTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    /// Set attributed Information text(Optional)
    var attributedInfoTitle: NSAttributedString? {
        didSet{
            detailView.attributedText = attributedInfoTitle
            detailView.isHidden = (attributedInfoTitle?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    /// Set water mark tint color
    var watermarkTint: UIColor = .lightGray{
        didSet{
            watermarkImage.tintColor = watermarkTint
        }
    }
    
    /// Set Info icon tint color
    var infoIconTint: UIColor = .gray{
        didSet{
            detailView.tint = infoIconTint
        }
    }
    
    /// Set customs view to set behind signature canvas image
    var waterMarkItems: [UIView]{
        get{
           return watermarkContainer.arrangedSubviews
        }
        set{
            newValue.forEach { item in
                watermarkContainer.addArrangedSubview(item)
            }
        }
    }
    
    /// Set watermark image
    var watermark: UIImage? {
        didSet{
            signatureComponentsView.typesHStack.isHidden = watermark != nil || isEraserHidden
            watermarkImage.image = watermark
        }
    }
    
    /// Set default sign image
    var signedImage: UIImage? {
        didSet{
            canvas.image = signedImage
        }
    }
    
    /// Set custom canvas size
    var canvasSize: CanvasSize = .fill{
        didSet{
            updateCanvasSize(canvasSize)
        }
    }
    
    /// Set size of sign image to be captured
    var capturedImageSize: CanvasSize = .fill
    
    var isResetButtonHidden: Bool = false{
        didSet{
            signatureComponentsView.undoButton.isHidden = isResetButtonHidden
        }
    }
    
    var isPickerButtonHidden: Bool = false{
        didSet{
            signatureComponentsView.pickerButton.isHidden = isPickerButtonHidden
        }
    }
    
    var isEraserHidden: Bool = false {
        didSet{
            signatureComponentsView.typesHStack.isHidden = watermark != nil || isEraserHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = F2F2F2_alpha1
        addViews()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        watermarkContainer.isHidden = true
        isParentNavigationBarHidden = self.navigationController?.isNavigationBarHidden ?? false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = isParentNavigationBarHidden
    }
    
    @objc private func didTapCapture(){
        delegate?.didTapCapture(onViewController: self, image: captureSign())
    }
    
    private func captureSign() -> UIImage{
        
        // Because in direct capture eraser color is visible on canvas and white lines of eraser is visible on view behind canvas.
        canvas.image = canvas.asImage
        
        // Clearing drawing so that if recaptured double signature is not captured.
        clearDrawing()
        
        watermarkContainer.isHidden = false
        drawingView.layer.cornerRadius = 0
        var image = drawingView.asImage
        drawingView.layer.cornerRadius = 8
        watermarkContainer.isHidden = true
        
        // Resize capture image in expected size.
        image = getResizedImage(size: capturedImageSize, image: image) ?? image
        
        return image
    }
    
}
extension UXSignatureViewController: UXSignatureComponentsViewDelegate{
    
    func didSelectEraser() {
        isPenEnabled = false
    }
    
    func didSelectPen() {
        isPenEnabled = true
    }
    
    func didTapUndo(){
        clearDrawing()
        canvas.image = nil
    }
    
    func didTapPicker(){
        
        if #available(iOS 14.0, *) {
            let viewC = UIColorPickerViewController()
            if #available(iOS 15.0, *) {
                (viewC.presentationController as? UISheetPresentationController)?.detents = [.medium(), .large()]
                (viewC.presentationController as? UISheetPresentationController)?.prefersGrabberVisible = true
            }
            viewC.selectedColor = penColor
            viewC.delegate = self
            present(viewC, animated: true)
        }
    }
    
    func didTapCross() {
        delegate?.didTapCross(onViewController: self)
    }
    
}
//MARK: Color Picker
extension UXSignatureViewController: UIColorPickerViewControllerDelegate{
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        penColor = viewController.selectedColor
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController){
        penColor = viewController.selectedColor
    }
}
//MARK: Draw Sign
extension UXSignatureViewController{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: canvas)
        signBezierPath.move(to: point)
        delegate?.didBeginSigning()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: canvas)
        signBezierPath.addLine(to: point)
        canvasLayer.path = signBezierPath.cgPath
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didEndSigning()
    }
    
    private func set(disabled: Bool, view: UIView){
        view.alpha = disabled ? 0.7 : 0.1
    }
}
extension UXSignatureViewController{
    
    private func clearDrawing(){
        signBezierPath.removeAllPoints()
        canvasLayer.path = signBezierPath.cgPath
    }
    
    private func resetLayer(isEraser: Bool){
        canvasLayer.strokeColor = isEraser ? canvasBackgroundColor.cgColor : penColor.cgColor
        canvasLayer.lineWidth = isEraser ? eraserLineWidth : penNibWidth
    }
    
    private func addViews(){
        self.view.addSubview(contentVStack)
        canvasContainer.addSubview(drawingView)
        drawingView.addSubview(watermarkContainer)
        drawingView.addSubview(canvas)
        self.canvas.layer.addSublayer(canvasLayer)
        contentVStack.addArrangedSubview(signatureComponentsView)
        contentVStack.addArrangedSubview(canvasContainer)
        contentVStack.addArrangedSubview(detailView)
        contentVStack.addArrangedSubview(doneButton)
        watermarkContainer.addArrangedSubview(watermarkImage)
    }
    
    private func addConstraints(){
        
        
        NSLayoutConstraint(item: contentVStack, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentVStack, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: contentVStack, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -12).isActive = true
        NSLayoutConstraint(item: contentVStack, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottomMargin, multiplier: 1, constant: -8).isActive = true
        
        doneButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        NSLayoutConstraint(item: drawingView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.canvasContainer, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: drawingView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self.canvasContainer, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: drawingView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.canvasContainer, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: drawingView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.canvasContainer, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: drawingView, attribute: .centerX, relatedBy: .equal, toItem: self.canvasContainer, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: drawingView, attribute: .centerY, relatedBy: .equal, toItem: self.canvasContainer, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        
        NSLayoutConstraint(item: watermarkContainer, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.canvas, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watermarkContainer, attribute: .leading, relatedBy: .equal, toItem: self.canvas, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watermarkContainer, attribute: .trailing, relatedBy: .equal, toItem: self.canvas, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watermarkContainer, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.canvas, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watermarkContainer, attribute: .centerX, relatedBy: .equal, toItem: self.canvas, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: watermarkContainer, attribute: .centerY, relatedBy: .equal, toItem: self.canvas, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        
        NSLayoutConstraint(item: canvas, attribute: .top, relatedBy: .equal, toItem: self.drawingView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: canvas, attribute: .leading, relatedBy: .equal, toItem: self.drawingView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: canvas, attribute: .trailing, relatedBy: .equal, toItem: self.drawingView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: canvas, attribute: .bottom, relatedBy: .equal, toItem: self.drawingView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        updateCanvasSize(canvasSize)
    }
    
    
    private func updateCanvasSize(_ size: CanvasSize){
        
        guard drawingView.superview != nil else { return }
        
        switch size{
        case .fill:
            drawingView.widthAnchor.constraint(equalTo: self.canvasContainer.widthAnchor, multiplier: 1).isActive = true
            drawingView.heightAnchor.constraint(equalTo: self.canvasContainer.heightAnchor, multiplier: 1).isActive = true
            break
        case .fixed(let width,let height):
            drawingView.widthAnchor.constraint(equalToConstant: width).isActive = true
            drawingView.heightAnchor.constraint(equalToConstant: height).isActive = true
            break
        case .fixedWidth(let width):
            drawingView.widthAnchor.constraint(equalToConstant: width).isActive = true
            drawingView.heightAnchor.constraint(equalTo: self.canvasContainer.heightAnchor, multiplier: 1).isActive = true
            break
        case .fixedHeight(let height):
            drawingView.heightAnchor.constraint(equalToConstant: height).isActive = true
            drawingView.widthAnchor.constraint(equalTo: self.canvasContainer.widthAnchor, multiplier: 1).isActive = true
            break
        }
    }
    
}
private extension UXSignatureViewController{
    
    func getResizedImage(size: CanvasSize, image: UIImage?) -> UIImage?{
        
        switch size {
        case .fixed(let width, let height):
            return resizeImage(image: image, targetSize: CGSize(width: width, height: height))
        case .fixedWidth(let width):
            return resizeImage(image: image, targetSize: CGSize(width: width, height: drawingView.bounds.size.height))
        case .fixedHeight(let height):
            return resizeImage(image: image, targetSize: CGSize(width: drawingView.bounds.size.width, height: height))
        default:
            return image
        }
    }
    
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        
        image?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension UIView{
    
    var asImage: UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
                        layer.render(in: rendererContext.cgContext)
        }
    }
}

