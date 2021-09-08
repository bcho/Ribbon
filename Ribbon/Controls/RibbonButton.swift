//
//  RibbonButton.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/19/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public class RibbonButton: Button, RibbonItemObserver {

    // MARK: - Stored Properties

    // MARK: Type

    #if canImport(UIKit)
    public static var minimumWidth: CGFloat = 30
    public static var height: CGFloat = 30
    #endif

    // MARK: Weak References

    public weak var item: RibbonItem?

    // MARK: Lazy

    #if canImport(UIKit)
    public lazy var heightConstraint = heightAnchor.constraint(equalToConstant: RibbonButton.height)
    #endif

    // MARK: Overridden

    #if canImport(UIKit)
    open override var intrinsicContentSize: CGSize {
        let superResult = super.intrinsicContentSize
        return CGSize(width: max(superResult.width, RibbonButton.minimumWidth), height: superResult.height)
    }

    open override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            if newValue {
                unhighlightTimer?.invalidate()
                unhighlightTimer = nil

                super.isHighlighted = newValue
            } else if unhighlightTimer == nil {
                unhighlightTimer = Timer.scheduledTimer(timeInterval: 0.15,
                                                        target: self,
                                                        selector: #selector(unhighlightTimerAction),
                                                        userInfo: nil,
                                                        repeats: false)
            }
        }
    }
    #endif

    // MARK: Private

    #if canImport(UIKit)
    private var unhighlightTimer: Timer?
    #endif

    // MARK: - Initializers

    // MARK: Designated

    public init(item: RibbonItem) {
        super.init(frame: .zero)

        self.item = item

        #if canImport(UIKit)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layer.cornerRadius = 5
        layer.borderWidth = 1

        translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13.0, *), item.controlKind == .action {
            translatesAutoresizingMaskIntoConstraints = false
            imageEdgeInsets.left = -4
            setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
            addInteraction(UIContextMenuInteraction(delegate: self))
        }

        addTarget(self, action: #selector(didTouchDownAction), for: .touchDown)
        addTarget(item, action: #selector(RibbonItem.sendAction(_:_:)), for: .touchUpInside)
        #else
        bezelStyle = .texturedRounded
        imagePosition = .imageOnly
        imageScaling = .scaleProportionallyUpOrDown
        target = item
        action = #selector(RibbonItem.sendAction(_:_:))
        #endif

        didChangeItem()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    // MARK: Life Cycle

    #if canImport(UIKit)
    open override func didMoveToSuperview() {
        heightConstraint.isActive = true

        super.didMoveToSuperview()
    }
    #endif

    // MARK: - Appearance Customization Methods

    #if canImport(UIKit)
    @available(iOS, introduced: 12.0, obsoleted: 13.0)
    open func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        let proxy = RibbonButton.appearance(for: UITraitCollection(userInterfaceStyle: style))

        backgroundColor = proxy.backgroundColor
        if let borderColor = proxy.borderColor() {
            setBorderColor(borderColor)
        }

        tintColor = proxy.tintColor
        setTitleColor(proxy.titleColor(for: .normal), for: .normal)
        setTitleColor(proxy.titleColor(for: .highlighted), for: .highlighted)
    }
    #endif

    // MARK: - Action Methods

    #if canImport(UIKit)
    @objc
    open func didTouchDownAction() {
        UIDevice.current.playInputClick()
    }

    @objc
    private func unhighlightTimerAction() {
        unhighlightTimer?.invalidate()
        unhighlightTimer = nil

        super.isHighlighted = false
    }

    @objc
    open func dismissContextMenuInteraction() {
        guard let contextMenuVC = window?.rootViewController?.presentedViewController
            else { return }

        assert(String(describing: type(of: contextMenuVC)).contains("Context"))

        contextMenuVC.dismiss(animated: true, completion: nil)
    }
    #endif

    // MARK: - RibbonItemObserver Protocol

    open func didChangeItem() {
        guard let item = item
            else { return }

        if let itemImage = item.image {
            setTitle(nil)
            setAttributedTitle(nil)
            setImage(itemImage)
        } else {
            #if canImport(UIKit)
            if #available(iOS 13.0, *), item.controlKind == .action {
                // Do nothing.
            } else {
                setImage(nil)
            }
            #else
            setImage(nil)
            #endif

            if item.usesAttributedTitle {
                setTitle(nil)
                setAttributedTitle(item.attributedTitle)
            } else {
                setAttributedTitle(nil)
                setTitle(item.title)
            }
        }

        isHidden = item.isHidden

        #if canImport(AppKit)
        keyEquivalent = item.keyEquivalent
        keyEquivalentModifierMask = item.keyEquivalentModifierMask
        toolTip = item.toolTip
        #endif

        invalidateIntrinsicContentSize()
    }

}

// MARK: - UIAppearanceContainer Protocol

#if canImport(UIKit)
extension RibbonButton {

    @objc
    public dynamic func borderColor() -> UIColor? {
        guard let cgColor = layer.borderColor
            else { return nil }
        return UIColor(cgColor: cgColor)
    }

    @objc
    public dynamic func setBorderColor(_ color: UIColor) {
        layer.borderColor = color.cgColor
    }

}
#endif

// MARK: - UIContextMenuInteractionDelegate Protocol & Friends

#if canImport(UIKit)
@available(iOS 13.0, *)
extension RibbonButton {

    private func contextMenuAction(_ action: UIAction) {
        guard let subitem = item?.subitems?.first(where: { $0.identifier == action.identifier.rawValue })
            else { return }
        subitem.sendAction(self, nil)
    }

    private func contextMenuActionProvider(_ suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard let actions = item?.subitems?.map({ UIAction(title: $0.title,
                                                           image: $0.image,
                                                           identifier: UIAction.Identifier($0.identifier),
                                                           handler: contextMenuAction) })
            else { return nil }
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: actions)
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                                configurationForMenuAtLocation location: CGPoint)
        -> UIContextMenuConfiguration? {
            guard let ribbon = item?.ribbon
                else { return nil }

            // A Force Touch gesture does not highlight the button.
            isHighlighted = true

            ribbon.presentingContextMenu = true
            ribbon.beginContextMenuInteraction()

            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: contextMenuActionProvider)
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                                willDisplayMenuFor configuration: UIContextMenuConfiguration,
                                                animator: UIContextMenuInteractionAnimating?) {
        guard let item = item, let ribbon = item.ribbon
            else { return }

        let block: () -> Void = { ribbon.presentingContextMenu = false }
        if let animator = animator {
            animator.addCompletion(block)
        } else {
            DispatchQueue.main.async(execute: block)
        }

        isUserInteractionEnabled = false
        isHighlighted = false

        ribbon.delegate?.ribbon?(contextMenuInteractionWillPresent: item.identifier)

        // Dismiss the interaction when the keyboard is used.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissContextMenuInteraction),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                                willEndFor configuration: UIContextMenuConfiguration,
                                                animator: UIContextMenuInteractionAnimating?) {
        guard let item = item, let ribbon = item.ribbon
            else { return }

        animator?.addCompletion {
            ribbon.hidingContextMenu = false

            DispatchQueue.main.async {
                ribbon.endContextMenuInteraction()
                self.isUserInteractionEnabled = true
            }
        }

        ribbon.hidingContextMenu = true
        ribbon.delegate?.ribbon?(contextMenuInteractionDidEnd: item.identifier)

        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidChangeNotification,
                                                  object: nil)
    }

    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                                previewForHighlightingMenuWithConfiguration
                                                    configuration: UIContextMenuConfiguration)
        -> UITargetedPreview? {
            let params = UIPreviewParameters()
            params.backgroundColor = .clear
            params.visiblePath = UIBezierPath(roundedRect: bounds,
                                              cornerRadius: 6)

            return UITargetedPreview(view: self, parameters: params)
    }

}
#endif
