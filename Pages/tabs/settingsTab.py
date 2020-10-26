import time

from appium.webdriver.common.touch_action import TouchAction
from selenium.webdriver.common.keys import Keys

import utilities.custom_logger as cl
import logging
from base.basepage import BasePage
from utilities.scrolling import Scrolling

class SettingsTab(BasePage):

    log = cl.customLogger(logging.INFO)

    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver

    #Locators
    _settings_tab = "//XCUIElementTypeButton[@name='Settings']"
    _terms_conditions = "//XCUIElementTypeStaticText[@name='Terms & Conditions']"
    _privacy_policy = "//XCUIElementTypeStaticText[@name='Privacy Policy']"
    _email_tab = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeTable/XCUIElementTypeCell[3]/XCUIElementTypeStaticText"
    _build_number = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeTable/XCUIElementTypeCell[4]/XCUIElementTypeStaticText"
    _sign_out = "//XCUIElementTypeStaticText[@name='Sign Out']"

    def SettingsTab(self):
        self.elementClick(self._settings_tab, locatorType="xpath")
        self.elementClick(self._terms_conditions, locatorType="xpath")
        self.elementClick(self._privacy_policy, locatorType="xpath")
        # self.elementClick(self._email_tab, locatorType="xpath")
        # self.getText(self._email_tab, locatorType="xpath")
        # self.elementClick(self._build_number, locatorType="xpath")
        # self.getText(self._build_number, locatorType="xpath")
        self.elementClick(self._sign_out, locatorType="xpath")

    def settingstab(self):
        self.SettingsTab()



