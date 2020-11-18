import datetime
import unittest
from selenium import webdriver
from appium import webdriver
from appium.webdriver.common.mobileby import MobileBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from Pages.home.login_page import LoginPage


class EnvironmentSetupBrowserstack(unittest.TestCase):

    def setUp(self):
        print("Running one time setUp at: "+str(datetime.datetime.now()))

        desired_cap = {
            # Set your access credentials
            "browserstack.user": "torontoqaspiriac1",
            "browserstack.key": "pmxn6rnEczeHs4cSxEzb",

            # Set URL of the application under test
            #"app_url": "bs://7c49467808f0d461092bfe6b06ee882505cb66d3",
            "app_url": "bs://9c51e8b7700fd14229090a21c22d2884c3c916b3",

            # Specify device and os_version for testing
            "device": "iPad 7th",
            "os_version": "13",

            # Set other BrowserStack capabilities
            "project": "Avecare-Educator",
            "build": "Python iOS",
            "name": "iOS_Educator UI TEST"
        }

        # Initialize the remote Webdriver using BrowserStack remote URL
        # and desired capabilities defined above
        self.driver = webdriver.Remote(
            command_executor="http://hub-cloud.browserstack.com/wd/hub",
            desired_capabilities=desired_cap
        )
        self.driver.implicitly_wait(6000)
        # Write your custom code here
        lp = LoginPage(self.driver)
        #lp.login("535cc_Room_300@avecare.com", "123456")
        lp.login("room100_littlemonkey@gmail.com", "Spiria123")

    def tearDown(self):
        if (self.driver != None):
            print("-------------------------------------------")
            print("Run Completed at : " + str(datetime.datetime.now()))
            self.driver.quit()

