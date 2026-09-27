import XCTest

@MainActor
final class FoundationFlowTests: XCTestCase {
    func testSetupValidationAndProgramNavigation() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let name = app.textFields["setup.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        capture(app, name: "Setup")
        let continueButton = app.buttons["setup.continue"]
        for _ in 0..<5 where !continueButton.isHittable { scrollContent(app, upward: true) }
        continueButton.tap()
        XCTAssertTrue(app.staticTexts["setup.error"].exists)
        for _ in 0..<5 where !name.isHittable { scrollContent(app, upward: false) }
        name.tap()
        name.typeText("Test Hunter\n")
        XCTAssertTrue(app.tabBars.buttons["System"].waitForExistence(timeout: 5))
        for tab in ["System", "Quests", "Hunter", "Arsenal", "Progress"] {
            XCTAssertTrue(app.tabBars.buttons[tab].exists)
        }
        app.tabBars.buttons["Quests"].tap()
        app.buttons["program.push"].tap()
        XCTAssertTrue(app.navigationBars["Push"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["exercise.push-bench-1"].exists)
        capture(app, name: "Push overview")
        app.tabBars.buttons["System"].tap()
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Personal Edition"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["capability.healthKit"].exists)
        capture(app, name: "Personal Edition capabilities")
    }

    func testLargeTextSetup() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.textFields["setup.name"].waitForExistence(timeout: 10))
        capture(app, name: "Setup accessibility text")
        for _ in 0..<5 where !app.textFields["setup.name"].isHittable { scrollContent(app, upward: true) }
        app.textFields["setup.name"].tap()
        app.textFields["setup.name"].typeText("Accessible Hunter")
        scrollContent(app, upward: true)
        let continueButton = app.buttons["setup.continue"]
        for _ in 0..<5 where !continueButton.isHittable { scrollContent(app, upward: true) }
        XCTAssertTrue(continueButton.isHittable)
        capture(app, name: "Accessible primary action")
        continueButton.tap()
        XCTAssertTrue(app.tabBars.buttons["System"].waitForExistence(timeout: 5))
    }

    private func scrollContent(_ app: XCUIApplication, upward: Bool) {
        // WHY: XCTest's default swipe can start behind the keyboard even on a ScrollView.
        // Intersect the actual visible content with the keyboard and navigation frames.
        let frame = app.scrollViews.firstMatch.frame.intersection(app.frame)
        let navigation = app.navigationBars.firstMatch
        let keyboard = app.keyboards.firstMatch
        let top = max(frame.minY, navigation.exists ? navigation.frame.maxY : frame.minY)
        let bottom = min(frame.maxY, keyboard.exists ? keyboard.frame.minY : frame.maxY)
        guard bottom > top else { XCTFail("No visible content area for scrolling"); return }
        let origin = app.coordinate(withNormalizedOffset: .zero)
        let x = frame.midX - app.frame.minX
        let upper = origin.withOffset(CGVector(dx: x, dy: top + (bottom - top) * 0.2 - app.frame.minY))
        let lower = origin.withOffset(CGVector(dx: x, dy: top + (bottom - top) * 0.8 - app.frame.minY))
        (upward ? lower : upper).press(forDuration: 0.05, thenDragTo: upward ? upper : lower)
    }

    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLaunchPerformance() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        measure(metrics: [XCTApplicationLaunchMetric()]) { app.launch() }
    }
}
