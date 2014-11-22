//
//  PPViewController.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

/**
 * Lightweight view controller subclass adding useful stuff to UIViewController, and which should be always used as
 * base class when creating view controller subclasses in projects using CoconutKit (provided you do not have to
 * subclass an existing view controller subclass which does not inherit from PPViewController, of course).
 *
 * PPViewController provides you with the following features:
 *   - localization is isolated in a single method. This is not only convenient to have a single place for localization code,
 *     but this also makes PPViewController compatible with the NSBundle+PPDynamicLocalization.h class extension, making
 *     it possible to change a view controller localization at runtime (if this is not needed, PPViewController of course
 *     remains compatible with the usual way of changing localization via system preferences, but it is stil good practice
 *     to collect localization code in a single method anyway)
 *   - view cleanup (-releaseViews) and general cleanup (-dealloc) are separated, enforcing good practices and eliminating
 *     potentially redundant code
 *   - instead of the default nib resolution mechanism of -[UIViewController init] (for @class MyViewController, first
 *     locate MyView.nib, then MyViewController.nib), PPViewController subclasses look for a nib bearing the same name
 *     as the class only (otherwise the view controller is assumed to be instantiated programmatically). This promotes
 *     a consistent naming scheme between source and nib files
 *   - view controllers inheriting from PPViewController MUST implement autorotation behavior using the new iOS 6
 *     -shouldAutorotate and -supportedInterfaceOrientations methods, not the old -shouldAutorotateToInterfaceOrientation:
 *     method anymore. This way, no code has to be duplicated to implement autorotation behavior for iOS 4 / 5 and 6
 *   - the way how methods must be overridden is clean and consistent: The rule is now "Always call the super implementation
 *     first" (if failing to do so, the behavior is undefined). This includes all view lifecycle methods, rotation methods,
 *     as well as -didReceiveMemoryWarning
 *
 * The PPViewController class is not meant to be instantiated directly, you should subclass it to define your own view
 * controllers.
 *
 * Otherwise, PPViewController is used exactly like UIViewController. There is only one major difference with
 * UIViewController: PPViewController supports all interface orientations by default. This choice was made so that
 * the "Always call the super implementation first" rule can be applied. This also makes sense from a user's perspective
 * since view controllers tend to support more and more orientations (especially since the iPad was launched, or more
 * recently with the autorotation behavior introduced in iOS 6).
 *
 * This class also provides a way to debug view controller events (lifecycle, rotation, memory warnings). You must
 * set the logger level of your application to DEBUG (see PPLogger.h to know how this is achieved). Then use the
 * console when running your application to have a look at view controller events. This most notably can help you
 * discover incorrect view controller hierarchies or poorly implemented view controller containers.
 *
 * Designated initializer: -initWithNibName:bundle:
 */
@interface PPViewController : UIViewController {
@protected
    struct {
        unsigned int appearsFirstTime           : 1;    //view controller appears first time
    } _PPViewControllerFlags;
}

@property (nonatomic, readonly, assign) BOOL appearsFirstTime;

/**
 * Instantiate a view controller, looking for a nib bearing the same name as the class in the given bundle. If the
 * specified bundle is nil, lookup is performed in the main bundle
 */
- (id)initWithBundle:(NSBundle *)nibBundleOrNil;

/**
 * Override this method in your subclass and release all views retained by the view controller in its implementation. This method
 * gets called automatically when deallocating or receiving a -viewDidUnload event. This allows to cleanly separate the object releasing
 * code of a view controller into two blocks:
 *   - in -releaseViews: Release all views created when loading the view, and retained by the view controller. If your view controller
 *     subclass retains view controllers to avoid creating their views too often ("view caching"), also set the views of thesee view
 *     controllers to nil in this method. If you are subclassing a class already subclassing PPViewController, always send the
 *     -releaseViews message to super first.
 *   - in -dealloc: Release all other resources owned by the view controller (model objects, other view controllers, views
 *     existing before the view is loaded, etc.)
 */
- (void)releaseViews;

/**
 * On iOS 4 and 5 (as well of course on iOS 6), implement this method to set whether the view controller should
 * autorotate or not
 *
 * Do not override -shouldAutorotateToInterfaceOrientation: when subclassing PPViewController, otherwise the behavior
 * is undefined
 */
- (BOOL)shouldAutorotate;

/**
 * On iOS 4 and 5 (as well of course on iOS 6), implement this method to set the orientations which a view
 * controller is compatible with
 *
 * Do not override -shouldAutorotateToInterfaceOrientation: when subclassing PPViewController, otherwise the behavior
 * is undefined
 */
- (NSUInteger)supportedInterfaceOrientations;
 
@end
