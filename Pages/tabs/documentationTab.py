import time

from appium.webdriver.common.touch_action import TouchAction
from pandas.tests.dtypes.test_missing import now
from selenium.webdriver.common.keys import Keys
import datetime as dt
import utilities.custom_logger as cl
import logging
from base.basepage import BasePage
from utilities.scrolling import Scrolling

class DocumentationTab(BasePage):

    log = cl.customLogger(logging.INFO)

    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver

    #Locators
    _document_tab = "//XCUIElementTypeButton[@name='Documentation']"
    _plus_icon = "//XCUIElementTypeButton[@name='plus icon']"
    _doc_title = "//XCUIElementTypeTextView"
    #_doc_title = "//XCUIElementTypeStaticText[@name='Type Your Title Here']"
    _add_pdf = "(//XCUIElementTypeImage[@name='no-pdf-placeholder'])[2]"
    #_add_pdf = "//XCUIElementTypeImage"
    #_select_photo = "//XCUIElementTypeCell[@name='Nikon, pdf']"
    _select_photo = "//XCUIElementTypeCell[@name='Flowers-1, pdf']/XCUIElementTypeOther/XCUIElementTypeOther"
    # _ipad_location = "//XCUIElementTypeButton[@name='Locations']"
    # _icloud_drive = "//XCUIElementTypeStaticText[@name='iCloud Drive']"
    # _browser = "//XCUIElementTypeButton[@name='Browse']"
    _publish_button = "//XCUIElementTypeButton[@name='Publish']"
    _browse_button = "//XCUIElementTypeButton[@name='BackButton']"
    _on_my_ipad = "//XCUIElementTypeStaticText[@name='On My iPad']"



    def DocumentTab(self):

        try:
            self.elementClick(self._document_tab, locatorType="xpath")
            self.elementClick(self._plus_icon, locatorType="xpath")
            #currentdate = dt.datetime.today().strftime("%m/%d/%Y")
            currentdate = now.strftime("%d/%m/%Y %H:%M:%S")
            self.sendKeys(currentdate, self._doc_title, locatorType="xpath")
            self.driver.hide_keyboard()
            self.elementClick(self._add_pdf, locatorType="xpath")
            time.sleep(3)
            self.elementClick(self._browse_button, locatorType="xpath")
            self.elementClick(self._on_my_ipad, locatorType="xpath")
            # self.elementClick(self._browser, locatorType="xpath")
            # self.elementClick(self._ipad_location, locatorType="xpath")
            # time.sleep(2)
            # self.elementClick(self._icloud_drive, locatorType="xpath")
            time.sleep(2)
            self.elementClick(self._select_photo, locatorType="xpath")
            time.sleep(2)
            self.elementClick(self._publish_button, locatorType="xpath")
            time.sleep(10)

        except:
            print("Something wrong with the script, please see logs")

    def doctab(self):
        self.DocumentTab()
