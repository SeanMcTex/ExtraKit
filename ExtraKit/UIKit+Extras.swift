import UIKit

extension UIView {
	func textFieldBecomeFirstResponder() -> Bool {
		if let tf = self as? UITextField {
			return tf.becomeFirstResponder()
		}
		for sv in subviews {
			if sv.textFieldBecomeFirstResponder() {
				return true
			}
		}
		return false
	}
}

extension UIViewController {
	func prepareForSegue(segue: UIStoryboardSegue, action: AnyObject?) -> Bool {
		guard let action = action as? SegueAction  else { return false }
		action.block(segue: segue)
		return true
	}
}

class SegueAction {
	var block: (segue: UIStoryboardSegue)->Void
	init(_ block: (segue: UIStoryboardSegue)->Void) {
		self.block = block
	}
}

extension UIViewController
{
	func typedParentViewController<T>() -> T? {
		return self as? T ?? parentViewController?.typedParentViewController()
	}
}

extension UIView {

	func typedParentViewController<T>() -> T? {
		return self as? T ?? parentViewController?.typedParentViewController()
	}

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}