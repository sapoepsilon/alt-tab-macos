import Cocoa

//class AppearanceTab: NSObject, NSTabViewDelegate {
//	static var grid: GridView!
//
//	static var appearanceTabManager: AppearanceTabManager!
//
//
//    static func initTab() -> NSView {
//		appearanceTabManager = AppearanceTabManager()
//		// Create tab view
//		let stackView = NSStackView(views: [appearanceTabManager.tabView])
//		grid = GridView([
//			[stackView]
//		])
//		alignGridView()
//		return grid
//    }
//
//	static func alignGridView() {
//		grid?.column(at: 0).xPlacement = .leading // or .fill or another appropriate alignment
//		grid?.fit()
//	}
//}

import Cocoa
import ShortcutRecorder

class AppearanceTab {
	static var shortcuts = [String: ATShortcut]()
	static var shortcutControls = [String: (CustomRecorderControl, String)]()
	static var rowsCount: [NSView] = []
	static var minWidthInRow: [NSView] = []
	static var maxWidthInRow: [NSView] = []
	static var grid: GridView!
	
	static func initTab() -> NSView {
		let tab1View = windowsTheme()
		let macOSView = macOSTheme()
		
		rowsCount = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Rows of thumbnails:", comment: ""), "rowsCount", 1, 20, 20, true)
		minWidthInRow = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window min width in row:", comment: ""), "windowMinWidthInRow", 1, 100, 10, true, "%", extraAction: { _ in self.capMinMaxWidthInRow() })
		maxWidthInRow = LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window max width in row:", comment: ""), "windowMaxWidthInRow", 1, 100, 10, true, "%", extraAction: { _ in self.capMinMaxWidthInRow() })
		
		let tabView = TabView([
			(NSLocalizedString("Windows", comment: ""), tab1View),
			(NSLocalizedString("MacOS", comment: ""), macOSView)
		])
		
		grid = GridView([
			[tabView]
		])

		tabView.rightAnchor.constraint(equalTo: grid.rightAnchor, constant: -GridView.padding).isActive = true

//		grid?.column(at: 0).gridView?.yPlacement = .leading
//		grid.fit()
		return grid
	}
	
	static func windowsTheme() -> GridView {
		return GridView([
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("Align windows:", comment: ""), "alignThumbnails", AlignThumbnailsPreference.allCases),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Max width on screen:", comment: ""), "maxWidthOnScreen", 10, 100, 10, true, "%"),
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide window thumbnails:", comment: ""), "hideThumbnails", extraAction: { _ in self.toggleRowsCount() }),
			rowsCount,
			minWidthInRow,
			maxWidthInRow,
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window app icon size:", comment: ""), "iconSize", 0, 128, 11, false, "px"),
			LabelAndControl.makeLabelWithSlider(NSLocalizedString("Window title font size:", comment: ""), "fontHeight", 0, 64, 11, false, "px"),
			LabelAndControl.makeLabelWithDropdown(NSLocalizedString("Window title truncation:", comment: ""), "titleTruncation", TitleTruncationPreference.allCases),
			// ... [add other controls for the windows theme as needed]
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Preview selected window:", comment: ""), "previewFocusedWindow"),
		])
	}
	
	static func macOSTheme() -> GridView {
		return GridView([
			LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Hide window thumbnails:", comment: ""), "hideThumbnails", extraAction: { _ in self.toggleRowsCount() }),
		])
	}
	
	static func capMinMaxWidthInRow() {
		let minSlider = minWidthInRow[1] as! NSSlider
		let maxSlider = maxWidthInRow[1] as! NSSlider
		maxSlider.minValue = minSlider.doubleValue
		LabelAndControl.controlWasChanged(maxSlider, "windowMaxWidthInRow")
	}
	
	static func toggleRowsCount() {
		(rowsCount[1] as! NSSlider).isEnabled = !Preferences.hideThumbnails
	}
}
