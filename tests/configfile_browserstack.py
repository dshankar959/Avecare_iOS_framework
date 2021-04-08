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
            "browserstack.user": "torontospiriaqa1",
            "browserstack.key": "qrbUCZsbBFyqhfb3MM97",
            ################################################## Used my own account ###########
            # "browserstack.user": "dferrari2",
            # "browserstack.key": "c9z8dL3Qk4XqR8y3zMkP",


            # Set URL of the application under test
            #"app_url": "bs://9c51e8b7700fd14229090a21c22d2884c3c916b3",
            "app_url": "bs://8c73164fb6e96e807fff1d6f31d0f1cc1294c946",

            # Specify device and os_version for testing
            "device": "iPad Air 4",
            "os_version": "14",
            "realMobile": "true",

            # Set other BrowserStack capabilities
            "project": "Avecare-Educator",
            "build": "Python iOS",
            "name": "iOS_Educator UI TEST"
        }

        """ Initialize the remote Webdriver using BrowserStack remote URL
         and desired capabilities defined above """
        self.driver = webdriver.Remote(
            command_executor="http://hub-cloud.browserstack.com/wd/hub",
            desired_capabilities=desired_cap
        )
        self.driver.implicitly_wait(6000)

        # Write your custom code here
        lp = LoginPage(self.driver)
        lp.login("room100_littlemonkey@gmail.com", "Spiria123")

    def tearDown(self):
        if (self.driver != None):
            print("-------------------------------------------")
            print("Run Completed at : " + str(datetime.datetime.now()))
            self.driver.quit()

