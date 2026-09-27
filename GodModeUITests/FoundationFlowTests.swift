import XCTest

@MainActor
final class FoundationFlowTests: XCTestCase {
    func testSetupValidationAndProgramNavigation() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        let name = app.textFields["setup.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
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
    }

    func testLaunchPerformance() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        measure(metrics: [XCTApplicationLaunchMetric()]) { app.launch() }
    }
}
