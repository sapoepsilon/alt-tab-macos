import Cocoa

class AppearanceTab: NSObject, NSTabViewDelegate {
	static var grid: GridView!

	static var appearanceTabManager: AppearanceTabManager!
	
	
    static func initTab() -> NSView {
		appearanceTabManager = AppearanceTabManager()
		// Create tab view
		let stackView = NSStackView(views: [appearanceTabManager.tabView])
		grid = GridView([
			[stackView]
		])
		alignGridView()
		return grid
    }

	static func alignGridView() {
		grid?.column(at: 0).xPlacement = .leading // or .fill or another appropriate alignment
		grid?.fit()
	}
}
