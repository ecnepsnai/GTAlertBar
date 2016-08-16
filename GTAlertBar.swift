import UIKit
import QuartzCore

public class GTAlertBarColors: NSObject {
    /// The background color of the alert bar.
    public var background: UIColor = UIColor.blackColor()

    /// The opacity amount for the background color.
    public var backgroundOpacity: CGFloat = 0.85

    /// The image tint color.
    public var image: UIColor = UIColor.whiteColor()

    /// The title label color.
    public var title: UIColor = UIColor.whiteColor()

    /// The body label color.
    public var body: UIColor = UIColor.whiteColor()
}

public class GTAlertBarAnimations: NSObject {
    /// Should the view slide down & up
    public var enabled: Bool = true

    /// Should the view fade in & out
    public var fade: Bool = false

    /// Duration of the animations
    public var duration: NSTimeInterval = 0.2
}

public class GTAlertBarSize: NSObject {
    /// The base height of the view. Will grow based off of the padding amount.
    public var baseHeight: CGFloat = 50.0

    /// The width of the view. Will use the width of the parent view if not specified.
    public var width: CGFloat?

    /// The amount of padding between elements.
    public var padding: CGFloat = 5
}

public class GTAlertBarCallbacks: NSObject {
    /// Called when the user tapped on the bar. The "tapToDismiss" setting has no affect on this callback.
    /// - parameter: bar The alert bar instance
    public var userTappedOnBar: ((bar: GTAlertBar) -> (Void))?
    
    /// Called when the bar was presented, after any aminations have completed
    /// - parameter: bar The alert bar instance
    public var barPresented: ((bar: GTAlertBar) -> (Void))?
    
    /// Called when the bar was dismissed, after any animations have completed
    /// - parameter: bar The alert bar instance
    /// - parameter: userDismissed True if the bar was dismissed by the user
    public var barDismissed: ((bar: GTAlertBar, userDismissed: Bool) -> (Void))?
}

public class GTAlertBarOptions: NSObject {
    /// Color properties.
    public var colors: GTAlertBarColors = GTAlertBarColors()

    /// Animation properties.
    public var animation: GTAlertBarAnimations = GTAlertBarAnimations()
    
    /// Size properties.
    public var size: GTAlertBarSize = GTAlertBarSize()
    
    /// Callbacks
    public var callbacks: GTAlertBarCallbacks = GTAlertBarCallbacks()

    /// Optional image for the bar. Specify your own image or use any of the included images in GTAlertBar.
    public var image: UIImage?

    /// Dismiss bar automatically after this amount of seconds. Set to 0.0 to never dismiss.
    public var dismissAfter: NSTimeInterval = 2.0

    /// Dismiss bar if user taps on it.
    public var tapToDismiss: Bool = true
}

public class GTAlertBarImage: NSObject {
    public static let exclamation: UIImage = {
        return UIImage(named: "fa-exclamation",
                       inBundle: NSBundle(forClass: GTAlertBar.self),
                       compatibleWithTraitCollection: nil)!
    }()
    
    public static let info: UIImage = {
        return UIImage(named: "fa-info",
                       inBundle: NSBundle(forClass: GTAlertBar.self),
                       compatibleWithTraitCollection: nil)!
    }()
    
    public static let caution: UIImage = {
        return UIImage(named: "fa-times-circle",
                       inBundle: NSBundle(forClass: GTAlertBar.self),
                       compatibleWithTraitCollection: nil)!
    }()
    
    public static let check: UIImage = {
        return UIImage(named: "fa-check",
                       inBundle: NSBundle(forClass: GTAlertBar.self),
                       compatibleWithTraitCollection: nil)!
    }()
}

public class GTAlertBar: NSObject {
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
    public class func barAttachedToView(viewController: UIViewController!,
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

        alertBarInstance.view.backgroundColor = options.colors.background.colorWithAlphaComponent(
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
        titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
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

        dispatch_async(dispatch_get_main_queue()) {
            alertBarInstance.addToParentView()
        }

        return alertBarInstance
    }

    ///  Remove all bars currently visible in the specified view controller
    ///
    ///  - parameter controller: The view controller to remove all bars from
    public class func removeAllBarsFromViewController(controller: UIViewController) {
        if let barsForView = GTAlertBar.bars[controller] {
            for bar in barsForView {
                bar.removeFromParentView(false)
            }
        }
    }

    /// Remove this bar from its parents view
    func removeFromParentView(userInitiated: Bool) {
        var indexOfRemovedBar: Int = 0
        if let barsForView = GTAlertBar.bars[self.parentViewController] {
            indexOfRemovedBar = barsForView.indexOfObject(self)
            barsForView.removeObject(self)
            if barsForView.count == 0 {
                GTAlertBar.bars.removeValueForKey(self.parentViewController)
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
            self.options.callbacks.barDismissed?(bar: self, userDismissed: userInitiated)
            self.view.removeFromSuperview()
        }
    }

    private func addToParentView() {
        if let barsForView = GTAlertBar.bars[self.parentViewController] {
            barsForView.addObject(self)
        } else {
            GTAlertBar.bars[self.parentViewController] = NSMutableArray(capacity: 100)
            GTAlertBar.bars[self.parentViewController]?.addObject(self)
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
                self.options.callbacks.barPresented?(bar: self)
                self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                    action: #selector(self.userTappedOnBar)))
                if self.options.dismissAfter != 0.0 {
                    self.performSelector(#selector(self.removeFromParentView),
                                         withObject: nil, afterDelay: self.options.dismissAfter)
                }
        }
    }
    
    @objc private func userTappedOnBar() {
        self.options.callbacks.userTappedOnBar?(bar: self)
        if self.options.tapToDismiss {
            self.removeFromParentView(true)
        }
    }

    private func allBarsForViewController() -> NSMutableArray {
        return GTAlertBar.bars[self.parentViewController]!
    }

    private func animateBlockWithDuration(duration: NSTimeInterval, block: () -> Void, completed: ((Bool) -> Void)?) {
        if self.options.animation.enabled {
            UIView.animateWithDuration(duration, animations: block, completion: completed)
        } else {
            block()
            completed?(true)
        }
    }

    private func shiftBarsAfterIndex(index: Int, removedHeight: CGFloat) {
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

    private func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
}
