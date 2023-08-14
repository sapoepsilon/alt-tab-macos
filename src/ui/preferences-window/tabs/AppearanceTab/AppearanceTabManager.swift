//
//  AppearanceTabManager.swift
//  alt-tab-macos
//
//  Created by Ismatulla Mansurov on 8/13/23.
//  Copyright © 2023 lwouis. All rights reserved.
//

import Foundation


class AppearanceTabManager: NSObject, NSTabViewDelegate {
	
	let tabView: NSTabView = NSTabView()
	var rowsCount: [NSView]!
	var minWidthInRow: [NSView]!
	var maxWidthInRow: [NSView]!

	required override init() {
		super.init()
		self.tabView.delegate = self
		rowsCount = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Rows of thumbnails:", comment: ""), "rowsCount", 1, 20, 20, true)
		minWidthInRow = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window min width in row:", comment: ""), "windowMinWidthInRow", 1, 100, 10, true, "%", extraAction: { _ in self.capMinMaxWidthInRow() })
		maxWidthInRow = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window max width in row:", comment: ""), "windowMaxWidthInRow", 1, 100, 10, true, "%", extraAction: { _ in self.capMinMaxWidthInRow() })
		self.setupTabs()
		toggleRowsCount()
		capMinMaxWidthInRow()
	}
	
	func createTab(tabLabel label: String, tabView view: GridView) -> NSTabViewItem {
		let tab = NSTabViewItem()
		tab.label = label
		tab.view = view
		return tab
	}
	
	func setupTabs() {
		var maxHeight: CGFloat = 300
		// Create tab items
		let windowsTab = createTab(tabLabel: "Windows", tabView: windowsTheme())
		let macOsTab = createTab(tabLabel: "MacOS", tabView: macOSTheme())
		let verticalTab = createTab(tabLabel: "Vertical", tabView: verticalTheme())
		let gnomeTab = createTab(tabLabel: "Gnome", tabView: createGnomeSpecificContent())
		
		let tabs: [NSTabViewItem] = [
			windowsTab, macOsTab, verticalTab, gnomeTab
		]
		


		// Add the tabs to the tab view
		for tab in tabs {
			tabView.addTabViewItem(tab)
		}
		
		// Set the frame size for the tab view based on the maximum height
		tabView.frame.size.height = maxHeight
	}
	
	func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		guard let label = tabViewItem?.label else { return }
		switch label {
		case "Windows":
			print("Did select label:: \(label)")
			print("Did select hash: \(tabViewItem?.hash ?? 0)")
			setWindowsTheme()
		case "MacOS":
			print("Did select label:: \(label)")
			print("Did select hash: \(tabViewItem?.hash ?? 0)")
			setMacOsTheme()
			// Add cases for other tabs if necessary
		default:
			break
		}
		DispatchQueue.main.async {
			(App.shared as! App).resetPreferencesDependentComponents()
		}
	}
	
	func resizeTabViewToFitItems(tabView: NSTabView) {
		var maxWidth: CGFloat = 0
		var maxHeight: CGFloat = 0
		
		for item in tabView.tabViewItems {
			if let view = item.view {
				maxWidth = max(maxWidth, view.frame.size.width)
				maxHeight = max(maxHeight, view.frame.size.height)
			}
		}
		
		tabView.setFrameSize(NSSize(width: maxWidth, height: maxHeight))
		AppearanceTab.grid?.column(at: 0).gridView?.yPlacement = .leading
		AppearanceTab.grid.fit()
	}

	
	func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
		DispatchQueue.main.async {
			self.resizeTabViewToFitItems(tabView: tabView)
		}
	}
	func setMacOsTheme() {
		Preferences.set("theme", ThemePreference.macOs.rawValue)
		Preferences.set("iconSize", "128")
		Preferences.set("hideThumbnails", "true")
		Preferences.set("windowMinWidthInRow", "3")
		Preferences.set("windowMinWidthInRow", "5")
	}	
	
	func setWindowsTheme() {
		Preferences.set("iconSize", "26")
		Preferences.set("hideThumbnails", "false")
	}
	func createInitialContent() -> GridView {
		// MARK: Load from the config and if not then create a default view
		return windowsTheme()
	}
	
	func windowsTheme() -> GridView {
		return GridView([
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("Align windows:", comment: ""), "alignThumbnails", AlignThumbnailsPreference.allCases),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Max width on screen:", comment: ""), "maxWidthOnScreen", 10, 100, 10, true, "%"),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Max height on screen:", comment: ""), "maxHeightOnScreen", 10, 100, 10, true, "%"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide window thumbnails:", comment: ""), "hideThumbnails", extraAction: { _ in self.toggleRowsCount() }),
			rowsCount,
			minWidthInRow,
			maxWidthInRow,
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window app icon size:", comment: ""), "iconSize", 0, 128, 11, false, "px"),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window title font size:", comment: ""), "fontHeight", 0, 64, 11, false, "px"),
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("Window title truncation:", comment: ""), "titleTruncation", TitleTruncationPreference.allCases),
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("Show on:", comment: ""), "showOnScreen", ShowOnScreenPreference.allCases),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Apparition delay:", comment: ""), "windowDisplayDelay", 0, 2000, 11, false, "ms"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Fade out animation:", comment: ""), "fadeOutAnimation"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide Space number labels:", comment: ""), "hideSpaceNumberLabels"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide status icons:", comment: ""), "hideStatusIcons"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Show standard tabs as windows:", comment: ""), "showTabsAsWindows"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide colored circles on mouse hover:", comment: ""), "hideColoredCircles"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide app badges:", comment: ""), "hideAppBadges"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide apps with no open window:", comment: ""), "hideWindowlessApps"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Preview selected window:", comment: ""), "previewFocusedWindow"),])
	}
	
	func macOSTheme() -> GridView {
		return GridView([
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide window thumbnails:", comment: ""), "hideThumbnails", extraAction: { _ in self.toggleRowsCount() }),
		])
	}
	
	func verticalTheme() -> GridView {
		LabelAndControl.makeTheme(themePreferenceHashValue: ThemePreference.macOs.hashValue)
		return GridView([
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("       :", comment: ""), "theme", ThemePreference.allCases)
		])
	}
	
	func createGnomeSpecificContent() -> GridView {
		
		return GridView([
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("       :", comment: ""), "theme", ThemePreference.allCases)
		])
	}
	
	func capMinMaxWidthInRow() {
		let minSlider = minWidthInRow[1] as! NSSlider
		let maxSlider = maxWidthInRow[1] as! NSSlider
		maxSlider.minValue = minSlider.doubleValue
		LabelAndControl.controlWasChanged(maxSlider, "windowMaxWidthInRow")
	}
	
	
	func toggleRowsCount() {
		(rowsCount[1] as! NSSlider).isEnabled = !Preferences.hideThumbnails
	}
	
	// Add other methods as needed
}
