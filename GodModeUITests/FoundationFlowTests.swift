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
        app.buttons["setup.continue"].tap()
        XCTAssertTrue(app.staticTexts["setup.error"].exists)
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
