//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

    
    
extension UITextView {
    
    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public override func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: UITextView {
    /// Reactive wrapper for `text` property
    public var text: ControlProperty<String?> {
        return value
    }
    
    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak textView = self.base] in
            let text = textView?.text
            
            let textChanged = textView?.textStorage
                // This project uses text storage notifications because
                // that's the only way to catch autocorrect changes
                // in all cases. Other suggestions are welcome.
                .rx.didProcessEditingRangeChangeInLength
                // This observe on is here because text storage
                // will emit event while process is not completely done,
                // so rebinding a value will cause an exception to be thrown.
                .observeOn(MainScheduler.asyncInstance)
                .map { _ in
                    return textView?.textStorage.string
                }
                ?? Observable.empty()
            
            return textChanged
                .startWith(text)
        }

        let bindingObserver = UIBindingObserver(UIElement: self.base) { (textView, text: String?) in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input 
            // when IME input method is used.
            if textView.text != text {
                textView.text = text
            }
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }

    /// Reactive wrapper for `delegate` message.
    public var didBeginEditing: ControlEvent<()> {
       return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidBeginEditing(_:)))
            .map { a in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    public var didEndEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidEndEditing(_:)))
            .map { a in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    public var didChange: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidChange(_:)))
            .map { a in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    public var didChangeSelection: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidChangeSelection(_:)))
            .map { a in
                return ()
            })
    }

}

#endif
