//
//  HoshiTextField.swift
//  TextFieldEffects
//
//  Created by Raúl Riera on 24/01/2015.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

/**
 An HoshiTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the lower edge of the control.
 */
@IBDesignable open class HoshiTextField: TextFieldEffects {
    /**
     Type of the HoshiTextField
     
     This property applies on the design of the text field it show rect around text field if it react and show a line underneath it if its linear
     */
    public enum HoshiTextType {
        case linear
        case rect
    }
    
    /**
     The color of the border when it has no content.

     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderInactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    /**
     The color of the border when it has content.

     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderActiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    /**
     The color of the placeholder text.

     This property applies a color to the complete placeholder string. The default value for this property is a black color.
     */
    @IBInspectable dynamic open var placeholderColor: UIColor = .black {
        didSet {
            updatePlaceholder()
        }
    }

    @IBInspectable dynamic open var placeholderActiveColor: UIColor = .black {
        didSet {
            updatePlaceholder()
        }
    }

    /**
     The scale of the placeholder font.

     This property determines the size of the placeholder label relative to the font size of the text field.
     */
    @IBInspectable dynamic open var placeholderFontScale: CGFloat = 0.65 {
        didSet {
            updatePlaceholder()
        }
    }
    
    /**
     Placeholder font.
     
     If placehodler font different then the text font then set placeholder font
     */
    @IBInspectable dynamic open var placeholderFont: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }
    
    /**
     Placeholder font.
     
     If placehodler font different then the text font then set placeholder font
     */
    @IBInspectable dynamic open var placeholderEmptyFont: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }

    override open var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    override open var bounds: CGRect {
        didSet {
            updateBorder()
            updatePlaceholder()
        }
    }

    private var borderThickness: (active: CGFloat, inactive: CGFloat) = (active: 2, inactive: 0.5)
    private let textFieldInsets = CGPoint(x: 0, y: 5)
    private let inactiveBorderLayer = CAShapeLayer()
    private let activeBorderLayer = CALayer()
    private let rectLayer = CALayer()
    
    public var hoshiTextType: HoshiTextType = .linear {
        didSet {
            updateHoshiType()
            updateBorder()
        }
    }
    
    public var clearButtonImage: UIImage? {
        didSet {
            clearButtonWithImage()
        }
    }
    
    /// For tunning text offset
    @IBInspectable public var textOffset: CGPoint = CGPoint(x: 0.0, y: 7.0) {
        didSet {
            setNeedsLayout()
        }
    }
    /// For tunning placeholder offset when field is focused
    @IBInspectable public var activePlaceholderOffset: CGPoint = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - TextFieldEffects

    override open func drawViewsForRect(_ rect: CGRect) {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: rect.size.width, height: rect.size.height))
        placeholderLabel.frame = frame

        updatePlaceholder()
        updateBorder()

        layer.addSublayer(inactiveBorderLayer)
        layer.addSublayer(activeBorderLayer)
        layer.addSublayer(rectLayer)
        addSubview(placeholderLabel)
    }

    override open func animateViewsForTextEntry() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: ({
            self.layoutPlaceholderInTextRect()
        }), completion: { _ in
            self.animationCompletionHandler?(.textEntry)
        })
        switch hoshiTextType {
        case .linear:
            activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: isEditing)
        case .rect:
            rectLayer.borderColor = isEditing ? borderActiveColor?.cgColor : borderInactiveColor?.cgColor
            rectLayer.borderWidth = isEditing ? borderThickness.active : borderThickness.inactive
            rectLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.width, height: frame.height))
        }
    }

    override open func animateViewsForTextDisplay() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: ({
            self.layoutPlaceholderInTextRect()
        }), completion: { _ in
            self.animationCompletionHandler?(.textDisplay)
        })
        switch hoshiTextType {
        case .linear:
            activeBorderLayer.frame = self.rectForBorder(self.borderThickness.active, isFilled: isEditing)
        case .rect:
            rectLayer.borderColor = isEditing ? borderActiveColor?.cgColor : borderInactiveColor?.cgColor
            rectLayer.borderWidth = isEditing ? borderThickness.active : borderThickness.inactive
            rectLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.width, height: frame.height))
        }
        placeholderLabel.textColor = isEditing ? placeholderActiveColor : (text ?? "").isEmpty ? placeholderColor : textColor
    }

    // MARK: - Private

    private func updateBorder() {
        switch hoshiTextType {
        case .linear:
            inactiveBorderLayer.frame = rectForBorder(borderThickness.inactive, isFilled: true)
            inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor
            
            activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: isEditing)
            activeBorderLayer.backgroundColor = borderActiveColor?.cgColor
        case .rect:
            inactiveBorderLayer.backgroundColor = nil
            activeBorderLayer.backgroundColor = nil
            rectLayer.borderColor = isEditing ? borderActiveColor?.cgColor : borderInactiveColor?.cgColor
            rectLayer.borderWidth = isEditing ? borderThickness.active : borderThickness.inactive
            rectLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.width, height: frame.height))
        }
        placeholderLabel.textColor = isEditing ? placeholderActiveColor : (text ?? "").isEmpty ? placeholderColor : textColor

    }

    private func updatePlaceholder() {
        let placeholderText = placeholder ?? ""
        placeholderLabel.text = (hoshiTextType == .linear || placeholderText.isEmpty) ? placeholderText : " \(placeholderText) "
        if isFirstResponder {
            placeholderLabel.textColor = placeholderActiveColor
        } else {
            placeholderLabel.textColor = placeholderColor
        }
        placeholderLabel.sizeToFit()
        switch hoshiTextType {
        case .linear:
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: ({
                self.layoutPlaceholderInTextRect()
            }), completion: { _ in })
            if isFirstResponder || !text!.isEmpty {
                animateViewsForTextEntry()
            }
        case .rect:
            layoutPlaceholderInTextRect()
            if isFirstResponder || !text!.isEmpty {
                animateViewsForTextEntry()
            }
        }
    }
    private func updateHoshiType() {
        switch hoshiTextType {
        case .linear:
            borderThickness = (active: 2, inactive: 0.5)
            inactiveBorderLayer.frame = rectForBorder(borderThickness.inactive, isFilled: true)
            inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor
            activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: isEditing)
            activeBorderLayer.backgroundColor = borderActiveColor?.cgColor
            rectLayer.borderColor = nil
            rectLayer.borderWidth = 0
            rectLayer.cornerRadius = 0
            placeholderLabel.backgroundColor = nil
        case .rect:
            borderThickness = (active: 2, inactive: 1)
            inactiveBorderLayer.backgroundColor = nil
            activeBorderLayer.backgroundColor = nil
            placeholderLabel.backgroundColor = .white
            rectLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.width, height: frame.height))
            rectLayer.borderColor = isEditing ? borderActiveColor?.cgColor : borderInactiveColor?.cgColor
            rectLayer.borderWidth = isEditing ? borderThickness.active : borderThickness.inactive
            rectLayer.cornerRadius = 4
            
        }
    }

    private func placeholderFontFromFont(_ font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * placeholderFontScale)
        return smallerFont
    }

    private func rectForBorder(_ thickness: CGFloat, isFilled: Bool) -> CGRect {
        if isFilled {
            return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness), size: CGSize(width: frame.width, height: thickness))
        } else {
            return CGRect(origin: CGPoint(x: 0, y: frame.height-thickness), size: CGSize(width: 0, height: thickness))
        }
    }

    private func layoutPlaceholderInTextRect() {
        if hoshiTextType == .rect {
            if isFirstResponder || !text!.isEmpty {
                if let boldFont  = placeholderLabel.font, let descriptor = boldFont.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold) {
                    placeholderLabel.font = placeholderFont ?? UIFont(descriptor:  descriptor, size: boldFont.pointSize)
                }
            } else {
                placeholderLabel.font = placeholderEmptyFont ?? placeholderFont ?? font
            }
        } else {
            if isFirstResponder || !(text ?? "").isEmpty {
                placeholderLabel.font =  placeholderFont ?? font
            } else {
                placeholderLabel.font = placeholderEmptyFont ?? placeholderFont ?? font
            }
        }
        placeholderLabel.sizeToFit()
        
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch self.textAlignment {
        case .center:
            originX += textRect.size.width / 2 - placeholderLabel.bounds.width / 2
        case .right:
            originX += textRect.size.width - placeholderLabel.bounds.width
        default:
            break
        }
        let action: () -> Void
        if isFirstResponder || !text!.isEmpty {
            action = {
                self.placeholderLabel.transform = CGAffineTransform(scaleX: self.placeholderFontScale, y: self.placeholderFontScale)
                self.placeholderLabel.textColor = self.placeholderActiveColor
                self.placeholderLabel.frame.origin = CGPoint(x: originX + self.activePlaceholderOffset.x, y: textRect.origin.y + self.activePlaceholderOffset.y)
            }
        } else {
            action = {
                self.placeholderLabel.transform = .identity
                self.placeholderLabel.textColor = self.placeholderColor
                self.placeholderLabel.frame.origin = CGPoint(x: originX, y: textRect.origin.y + (textRect.height - self.placeholderLabel.bounds.height) / 2.0)
            }
        }

        // animate transition only if field is active
        if isFirstResponder {
            action()
        } else {
            UIView.performWithoutAnimation(action)
        }
    }
    
    private func clearButtonWithImage() {
        if let image = clearButtonImage {
            let clearButton = UIButton()
            clearButton.accessibilityLabel = "Clear text field"
            clearButton.setImage(image, for: .normal)
            clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            clearButton.contentMode = .scaleAspectFit
            clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
            self.rightView = clearButton
            self.rightViewMode = .whileEditing
            self.clearButtonMode = .whileEditing
        }
    }
    
    @objc private func clear(sender: AnyObject) {
        self.text = ""
    }
    
    func makeInactiveBorderDashed() {
        borderInactiveColor = nil
        inactiveBorderLayer.backgroundColor = nil
        inactiveBorderLayer.strokeColor = UIColor.gray.cgColor
        inactiveBorderLayer.lineDashPattern = [3, 2]
        inactiveBorderLayer.lineWidth = 1.0
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        inactiveBorderLayer.path = path.cgPath
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        inactiveBorderLayer.path = path.cgPath
    }

    // MARK: - Overrides

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.offsetBy(dx: textOffset.x + (leftView != nil ? leftView!.bounds.width + 10.0 : 0.0), dy: textOffset.y)
        rect.size.width = rect.width - 2 * textOffset.x - ((clearButtonMode == .never) ? 0 : 10)
        return rect
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.offsetBy(dx: textOffset.x + (leftView != nil ? leftView!.bounds.width + 10.0 : 0.0), dy: textOffset.y)
        rect.size.width = rect.width - 2 * textOffset.x - ((clearButtonMode == .never) ? 0 : 10)
        return rect
    }
    
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x -= 10;
        return rightViewRect
    }
}
