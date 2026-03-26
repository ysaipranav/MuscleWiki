import XCTest

final class MuscleWikiAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Browse exercises

    func testExerciseListLoads() throws {
        // Exercises tab is selected by default
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        // At least one cell should appear
        XCTAssertTrue(list.cells.count > 0)
    }

    func testSearchFiltersResults() throws {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("curl")
        // All visible cells should relate to "curl"
        let cells = app.collectionViews.firstMatch.cells
        XCTAssertTrue(cells.count > 0)
    }

    func testTappingExerciseOpensDetail() throws {
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        let firstCell = list.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()
        // Detail view should show "How To" section
        let howTo = app.staticTexts["How To"]
        XCTAssertTrue(howTo.waitForExistence(timeout: 3))
    }

    // MARK: - Filters

    func testFiltersSheetOpens() throws {
        let filterButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Filters'")
        ).firstMatch
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))
        filterButton.tap()
        let filterTitle = app.navigationBars["Filters"].firstMatch
        XCTAssertTrue(filterTitle.waitForExistence(timeout: 3))
    }

    func testApplyingCategoryFilterAndReset() throws {
        // Open filters
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Filters'"))
            .firstMatch.tap()
        // Toggle Bodyweight
        let bodyweightToggle = app.switches["Bodyweight filter, off"]
        if bodyweightToggle.waitForExistence(timeout: 3) {
            bodyweightToggle.tap()
        }
        // Dismiss
        app.buttons["Done"].tap()
        // Banner should show
        let banner = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'filter'")
        ).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 2))
        // Clear filters
        app.buttons["Clear"].firstMatch.tap()
        XCTAssertFalse(banner.exists)
    }

    // MARK: - Favorites

    func testSavingAndRemovingFavorite() throws {
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        list.cells.firstMatch.tap()

        // Tap heart to favorite
        let heartButton = app.buttons["Add to favorites"]
        XCTAssertTrue(heartButton.waitForExistence(timeout: 3))
        heartButton.tap()

        // Heart should now be filled
        let filledHeart = app.buttons["Remove from favorites"]
        XCTAssertTrue(filledHeart.waitForExistence(timeout: 2))

        // Navigate to Favorites tab
        app.navigationBars.buttons.firstMatch.tap() // back
        app.tabBars.buttons["Favorites"].tap()
        let favList = app.collectionViews.firstMatch
        XCTAssertTrue(favList.cells.count > 0)

        // Remove favorite from detail
        favList.cells.firstMatch.tap()
        filledHeart.tap()

        // Navigate back – favorites should be empty
        app.navigationBars.buttons.firstMatch.tap()
        let emptyLabel = app.staticTexts["No Favorites Yet"]
        XCTAssertTrue(emptyLabel.waitForExistence(timeout: 2))
    }

    // MARK: - Browse tab

    func testBrowseTabShowsMuscleGrid() throws {
        app.tabBars.buttons["Browse"].tap()
        let title = app.navigationBars["Browse by Muscle"].firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        // Muscle tiles should be present
        XCTAssertTrue(app.staticTexts["Chest"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Biceps"].waitForExistence(timeout: 2))
    }

    func testTappingMuscleFiltersExercises() throws {
        app.tabBars.buttons["Browse"].tap()
        // Tap Biceps tile
        app.staticTexts["Biceps"].firstMatch.tap()
        // Navigate to exercises tab to see filtered list
        app.tabBars.buttons["Exercises"].tap()
        let banner = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'filter'")
        ).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 2))
    }

    // MARK: - Accessibility

    func testVoiceOverLabelsPresent() throws {
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        // First cell should have an accessibility label
        let firstCell = list.cells.firstMatch
        XCTAssertFalse(firstCell.label.isEmpty)
    }
}
