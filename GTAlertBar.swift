import UIKit
import QuartzCore

open class GTAlertBarColors: NSObject {
    /// The background color of the alert bar.
    open var background: UIColor = UIColor.black

    /// The opacity amount for the background color.
    open var backgroundOpacity: CGFloat = 0.85

    /// The image tint color.
    open var image: UIColor = UIColor.white

    /// The title label color.
    open var title: UIColor = UIColor.white

    /// The body label color.
    open var body: UIColor = UIColor.white
}

open class GTAlertBarAnimations: NSObject {
    /// Should the view slide down & up
    open var enabled: Bool = true

    /// Should the view fade in & out
    open var fade: Bool = false

    /// Duration of the animations
    open var duration: TimeInterval = 0.2
}

open class GTAlertBarSize: NSObject {
    /// The base height of the view. Will grow based off of the padding amount.
    open var baseHeight: CGFloat = 50.0

    /// The width of the view. Will use the width of the parent view if not specified.
    open var width: CGFloat?

    /// The amount of padding between elements.
    open var padding: CGFloat = 5
}

open class GTAlertBarCallbacks: NSObject {
    /// Called when the user tapped on the bar. The "tapToDismiss" setting has no affect on this callback.
    /// - parameter: bar The alert bar instance
    open var userTappedOnBar: ((_ bar: GTAlertBar) -> (Void))?
    
    /// Called when the bar was presented, after any aminations have completed
    /// - parameter: bar The alert bar instance
    open var barPresented: ((_ bar: GTAlertBar) -> (Void))?
    
    /// Called when the bar was dismissed, after any animations have completed
    /// - parameter: bar The alert bar instance
    /// - parameter: userDismissed True if the bar was dismissed by the user
    open var barDismissed: ((_ bar: GTAlertBar, _ userDismissed: Bool) -> (Void))?
}

open class GTAlertBarOptions: NSObject {
    /// Color properties.
    open var colors: GTAlertBarColors = GTAlertBarColors()

    /// Animation properties.
    open var animation: GTAlertBarAnimations = GTAlertBarAnimations()
    
    /// Size properties.
    open var size: GTAlertBarSize = GTAlertBarSize()
    
    /// Callbacks
    open var callbacks: GTAlertBarCallbacks = GTAlertBarCallbacks()

    /// Optional image for the bar. Specify your own image or use any of the included images in GTAlertBar.
    open var image: UIImage?

    /// Dismiss bar automatically after this amount of seconds. Set to 0.0 to never dismiss.
    open var dismissAfter: TimeInterval = 2.0

    /// Dismiss bar if user taps on it.
    open var tapToDismiss: Bool = true
}

open class GTAlertBarImage: NSObject {
    open static let exclamation: UIImage = {
        return UIImage(named: "fa-exclamation",
                       in: Bundle(for: GTAlertBar.self),
                       compatibleWith: nil)!
    }()
    
    open static let info: UIImage = {
        return UIImage(named: "fa-info",
                       in: Bundle(for: GTAlertBar.self),
                       compatibleWith: nil)!
    }()
    
    open static let caution: UIImage = {
        return UIImage(named: "fa-times-circle",
                       in: Bundle(for: GTAlertBar.self),
                       compatibleWith: nil)!
    }()
    
    open static let check: UIImage = {
        return UIImage(named: "fa-check",
                       in: Bundle(for: GTAlertBar.self),
                       compatibleWith: nil)!
    }()
}

open class GTAlertBar: NSObject {
    static var bars: [UIViewController:NSMutableArray] = [:]

    var options: GTAlertBarOptions!
    var view: UIView!
    var parentViewController: UIViewController!

    ///  Attach a GTAlertBar to the top of the view controller
    ///
    ///  - parameter viewController: The view controller to attach to
    ///  - parameter title:          The title of the alert
    ///  - parameter body:           Optional body of the alert
    ///  - parameter options:        Alert options
    ///
    ///  - returns: The GTAlertBar instance
    open class func barAttachedToView(_ viewController: UIViewController!,
                                 title: String!,
                                 body: String?,
                                 options: GTAlertBarOptions!) -> GTAlertBar {
        let alertBarInstance: GTAlertBar = GTAlertBar()
        alertBarInstance.options = options
        var barY: CGFloat = viewController.view.frame.origin.y + alertBarInstance.statusBarHeight()
        if let navigationCotroller = viewController.navigationController {
            barY += navigationCotroller.navigationBar.frame.size.height
        }
        alertBarInstance.options.size.baseHeight += (options.size.padding * 2)
        alertBarInstance.view = UIView(frame: CGRect(x: viewController.view.frame.origin.x,
            y: barY - alertBarInstance.options.size.baseHeight,
            width: options.size.width ?? viewController.view.frame.size.width,
            height: alertBarInstance.options.size.baseHeight))
        alertBarInstance.parentViewController = viewController

        alertBarInstance.view.backgroundColor = options.colors.background.withAlphaComponent(
            options.colors.backgroundOpacity)
        alertBarInstance.view.layer.opacity = options.animation.fade ? 0.0 : 1.0

        var startXPosition: CGFloat!
        if let image = options.image {
            let imagePadding: CGFloat = options.size.padding * 2
            let size: CGFloat = alertBarInstance.view.frame.size.height - (imagePadding * 2)
            let imageFrame: CGRect = CGRect(x: imagePadding,
                                            y: imagePadding,
                                            width: size,
                                            height: size)
            let imageView: UIImageView = UIImageView(frame: imageFrame)
            imageView.image = image
            alertBarInstance.view.addSubview(imageView)
            startXPosition = size + (imagePadding * 2)
        } else {
            startXPosition = options.size.padding
        }

        let titleLabelYPosition: CGFloat = options.size.padding
        let titleLabel: UILabel = UILabel(frame: CGRect(x: startXPosition,
            y: titleLabelYPosition,
            width: 0,
            height: 0))
        titleLabel.text = title
        titleLabel.textColor = options.colors.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        titleLabel.sizeToFit()
        alertBarInstance.view.addSubview(titleLabel)

        if let bodyText = body {
            let bodyLabelYPosition: CGFloat = titleLabelYPosition + titleLabel.frame.size.height + options.size.padding
            let bodyLabel: UILabel = UILabel(frame: CGRect(x: startXPosition,
                y: bodyLabelYPosition,
                width: 0,
                height: 0))
            bodyLabel.text = bodyText
            bodyLabel.textColor = options.colors.body
            bodyLabel.sizeToFit()
            alertBarInstance.view.addSubview(bodyLabel)
        } else {
            var frame: CGRect = titleLabel.frame
            frame.size.height = alertBarInstance.view.frame.size.height - (options.size.padding * 2)
            titleLabel.frame = frame
        }

        DispatchQueue.main.async {
            alertBarInstance.addToParentView()
        }

        return alertBarInstance
    }

    ///  Remove all bars currently visible in the specified view controller
    ///
    ///  - parameter controller: The view controller to remove all bars from
    open class func removeAllBarsFromViewController(_ controller: UIViewController) {
        if let barsForView = GTAlertBar.bars[controller] {
            for bar in barsForView {
                (bar as! GTAlertBar).removeFromParentView(false)
            }
        }
    }

    /// Remove this bar from its parents view
    func removeFromParentView(_ userInitiated: Bool) {
        var indexOfRemovedBar: Int = 0
        if let barsForView = GTAlertBar.bars[self.parentViewController] {
            indexOfRemovedBar = barsForView.index(of: self)
            barsForView.remove(self)
            if barsForView.count == 0 {
                GTAlertBar.bars.removeValue(forKey: self.parentViewController)
            }
        }
        self.shiftBarsAfterIndex(indexOfRemovedBar, removedHeight: self.view.frame.size.height)
        self.animateBlockWithDuration(self.options.animation.duration, block: {
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                y: self.view.frame.origin.y - self.view.frame.size.height,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height)
            if self.options.animation.fade {
                self.view.layer.opacity = 0.0
            }
        }) { (Bool) in
            self.options.callbacks.barDismissed?(self, userInitiated)
            self.view.removeFromSuperview()
        }
    }

    fileprivate func addToParentView() {
        if let barsForView = GTAlertBar.bars[self.parentViewController] {
            barsForView.add(self)
        } else {
            GTAlertBar.bars[self.parentViewController] = NSMutableArray(capacity: 100)
            GTAlertBar.bars[self.parentViewController]?.add(self)
        }
        var barY: CGFloat = self.view.frame.origin.y
        for bar in GTAlertBar.bars[self.parentViewController]! {
            barY += (bar as! GTAlertBar).view.frame.size.height
        }
        self.view.layer.zPosition = 100 - CGFloat(self.allBarsForViewController().count)
        self.parentViewController.view.addSubview(self.view)
        self.animateBlockWithDuration(self.options.animation.duration, block: {
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                y: barY,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height)
            if self.options.animation.fade {
                self.view.layer.opacity = 1.0
            }
            }) { (finished) in
                self.options.callbacks.barPresented?(self)
                self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                    action: #selector(self.userTappedOnBar)))
                if self.options.dismissAfter != 0.0 {
                    self.perform(#selector(self.removeFromParentView),
                                         with: nil, afterDelay: self.options.dismissAfter)
                }
        }
    }
    
    @objc fileprivate func userTappedOnBar() {
        self.options.callbacks.userTappedOnBar?(self)
        if self.options.tapToDismiss {
            self.removeFromParentView(true)
        }
    }

    fileprivate func allBarsForViewController() -> NSMutableArray {
        return GTAlertBar.bars[self.parentViewController]!
    }

    fileprivate func animateBlockWithDuration(_ duration: TimeInterval, block: @escaping () -> Void, completed: ((Bool) -> Void)?) {
        if self.options.animation.enabled {
            UIView.animate(withDuration: duration, animations: block, completion: completed)
        } else {
            block()
            completed?(true)
        }
    }

    fileprivate func shiftBarsAfterIndex(_ index: Int, removedHeight: CGFloat) {
        self.animateBlockWithDuration(self.options.animation.duration, block: {
            var i: Int = index
            var bar: GTAlertBar!
            while i < (GTAlertBar.bars[self.parentViewController] ?? []).count {
                bar = GTAlertBar.bars[self.parentViewController]![i] as! GTAlertBar
                bar.view.frame = CGRect(x: bar.view.frame.origin.x,
                    y: bar.view.frame.origin.y - removedHeight,
                    width: bar.view.frame.size.width,
                    height: bar.view.frame.size.height)
                i += 1
            }
        }, completed: nil)
    }

    fileprivate func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
}
