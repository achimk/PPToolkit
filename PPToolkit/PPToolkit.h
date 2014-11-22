//
//  PPToolkit.h
//  PPToolkit
//
//  Created by Joachim Kret on 03.03.2013.
//  Copyright (c) 2013 Joachim Kret. All rights reserved.
//

//Third Party Libs
#import "PPToolkit/Vendors/FCYAsserts/FCYAsserts.h"

//Protocols
#import "PPToolkit/Protocols/PPLoadingContentProtocol.h"
#import "PPToolkit/Protocols/PPPageScrollViewProtocol.h"

//Core
#import "PPToolkit/Core/PPRuntime.h"

//View Controllers - Protocols / Misc
#import "PPToolkit/ViewControllers/PPAutorotation.h"
#import "PPToolkit/ViewControllers/PPAutorotationCompatibility.h"

//View Controllers - Extensions
#import "PPToolkit/ViewControllers/UIViewController+PPToolkitExtensions.h"
#import "PPToolkit/ViewControllers/UINavigationController+PPToolkitExtensions.h"
#import "PPToolkit/ViewControllers/UITabBarController+PPToolkitExtensions.h"
#import "PPToolkit/ViewControllers/UIPopoverController+PPToolkitExtensions.h"
#import "PPToolkit/ViewControllers/UISplitViewController+PPToolkitExtensions.h"

//View Controllers
#import "PPToolkit/ViewControllers/PPNavigationController.h"
#import "PPToolkit/ViewControllers/PPViewController.h"
#import "PPToolkit/ViewControllers/PPKeyboardViewController.h"
#import "PPToolkit/ViewControllers/PPManagedViewController.h"

//Table View Controllers
#import "PPToolkit/ViewControllers/PPTableViewController.h"
#import "PPToolkit/ViewControllers/PPLoadingTableViewController.h"
#import "PPToolkit/ViewControllers/PPManagedTableViewController.h"
#import "PPToolkit/ViewControllers/PPManagedLoadingTableViewController.h"

//Collection View Controllers
#import "PPToolkit/ViewControllers/PPCollectionViewController.h"
#import "PPToolkit/ViewControllers/PPLoadingCollectionViewController.h"
#import "PPToolkit/ViewControllers/PPManagedCollectionViewController.h"
#import "PPToolkit/ViewControllers/PPManagedLoadingCollectionViewController.h"

//Custom Controllers
#import "PPToolkit/CustomControllers/PPSwitchViewController.h"
#import "PPToolkit/CustomControllers/PPSegmentedViewController.h"
#import "PPToolkit/CustomControllers/PPSheetController.h"
#import "PPToolkit/CustomControllers/PPSemiSheetController.h"

//Models - CoreData
#import "PPToolkit/Models/PPCoreDataStore.h"
#import "PPToolkit/Models/PPManagedObjectContext.h"
#import "PPToolkit/Models/PPManagedObject.h"
#import "PPToolkit/Models/PPRemoteManagedObject.h"

//Models
#import "PPToolkit/Models/PPDelegateManager.h"
#import "PPToolkit/Models/PPObjectInterceptor.h"
#import "PPToolkit/Models/PPDelegateInterceptor.h"
#import "PPToolkit/Models/PPCache.h"

//Models - OperationQueue
#import "PPToolkit/Models/PPOperationQueue.h"

//Models - Operations
#import "PPToolkit/Models/PPOperation.h"
#import "PPToolkit/Models/PPKVOOperation.h"
#import "PPToolkit/Models/PPDispatchOperation.h"
#import "PPToolkit/Models/PPStateMachineOperation.h"
#import "PPToolkit/Models/PPGroupOperation.h"
#import "PPToolkit/Models/PPKVOGroupOperation.h"
#import "PPToolkit/Models/PPDispatchGroupOperation.h"

//Models - OperationQueue Support
#import "PPToolkit/Models/PPProgressObserver.h"
#import "PPToolkit/Models/PPOperationStateMachine.h"

//Controls
#import "PPToolkit/Controls/PPButton.h"
#import "PPToolkit/Controls/PPTextField.h"

//Views
#import "PPToolkit/Views/PPGradientLayer.h" //???: should we move to other folder?
#import "PPToolkit/Views/PPGradientView.h"
#import "PPToolkit/Views/PPLoadingView.h"
#import "PPToolkit/Views/PPPageScrollView.h"
#import "PPToolkit/Views/PPPageScrollViewCell.h"

//Views - TableView
#import "PPToolkit/Views/PPTableView.h"

//Views - TableView Cell Accessory Views
#import "PPToolkit/Views/PPAccessoryView.h"

//Views - TableView Cell Backgrounds
#import "PPToolkit/Views/PPTableCellBackgroundView.h"

//Views - TableView Cells
#import "PPToolkit/Views/PPTableViewCell.h"
#import "PPToolkit/Views/PPDefaultTableViewCell.h"
#import "PPToolkit/Views/PPRightDetailTableViewCell.h"
#import "PPToolkit/Views/PPSubtitleDetailTableViewCell.h"
#import "PPToolkit/Views/PPLoadingTableViewCell.h"

//Vendors - PSTCollectionView
#import "PPToolkit/Vendors/PSTCollectionView/PSTCollectionViewCommon.h"
#import "PPToolkit/Vendors/PSTCollectionView/PSTCollectionView.h"

//Views - CollectionView Cell Backgrounds
#import "PPToolkit/Views/PPCollectionCellBackgroundView.h"

//Views - CollectionView Cells
#import "PPToolkit/Views/PPCollectionViewCell.h"
#import "PPToolkit/Views/PPLoadingCollectionViewCell.h"

//Utilities
#import "PPToolkit/Utilities/PPToolkitDefines.h"
#import "PPToolkit/Utilities/PPSynthesizeSingleton.h"
#import "PPToolkit/Utilities/PPDrawingUtilities.h"
