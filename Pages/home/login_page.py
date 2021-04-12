
from base.selenium_driver import SeleniumDriver
import utilities.custom_logger as cl
import logging
from base.basepage import BasePage

class LoginPage(BasePage):

    log = cl.customLogger(logging.DEBUG)

    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver

    #Locators
    #_email_field = "//XCUIElementTypeTextField[@name='Email']"
    _email_field = "//XCUIElementTypeTextField[@name='ui_loginField']"
    #_password_field = "//XCUIElementTypeSecureTextField[@name='Password']"
    _password_field = "//XCUIElementTypeSecureTextField[@name='ui_passwordField']"
   # _signin_button = "//XCUIElementTypeButton[@name='Sign In']"
    _signin_button = "//XCUIElementTypeButton[@name='ui_loginButton']"
    _login_logo = "hwcccc-logo-icon"
    _first_name_tab = "//XCUIElementTypeButton[@name='First Name']"

    #### Methods to perform action

    def enterEmail(self, email):
        emailField = self.getElement(self._email_field, locatorType="xpath")
        emailField.clear()
        self.sendKeys(email, self._email_field, locatorType="xpath")

    def enterPassword(self, password):
        passwordField = self.getElement(self._password_field, locatorType="xpath")
        passwordField.clear()
        self.sendKeys(password, self._password_field, locatorType="xpath")

    def clicksigninButton(self):
        self.elementClick(self._signin_button, locatorType="xpath")


    def login(self, email, password):
        self.enterEmail(email)
        self.enterPassword(password)
        self.clicksigninButton()

    def verifyLoginSuccessful(self):
        logo = self.isElementPresent(self._first_name_tab, locatorType="xpath")
        print("Login success")
        return logo





