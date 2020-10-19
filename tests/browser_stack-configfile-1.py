import datetime
from selenium import webdriver
from _pytest import unittest
from appium import webdriver
from appium.webdriver.common.mobileby import MobileBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from Pages.home.login_page import LoginPage


class EnvironmentSetuptest(unittest.UnitTestCase):

    def setUp(self):
        print("Running one time setUp at: "+str(datetime.datetime.now()))
        self.desired_caps = {}
        # Set your access credentials
        self.desired_caps['browserstack.user'] = 'torontoqaspiriac1',
        self.desired_caps['browserstack.key'] =  'pmxn6rnEczeHs4cSxEzb',

        # Set URL of the application under test
        self.desired_caps['app_url'] = 'bs://7c49467808f0d461092bfe6b06ee882505cb66d3',

        # Specify device and os_version for testing
        self.desired_caps['device'] = 'iPad 7th',
        self.desired_caps['os_version'] = '13',

        # Set other BrowserStack capabilities
        self.desired_caps ['project'] = 'Avecare-Educator',
        self.desired_caps['build'] = 'Python iOS',
        self.desired_caps['name'] = 'first_test'
        self.driver = webdriver.Remote(
            command_executor="http://hub-cloud.browserstack.com/wd/hub",
            desired_capabilities=self.desired_caps)

        lp = LoginPage(self.driver)
        #lp.login("535cc_Room_300@avecare.com", "123456")
        lp.login("room100_littlemonkey@gmail.com", "Spiria123")


    def tearDown(self):
        if (self.driver != None):
            print("-------------------------------------------")
            print("Run Completed at : " + str(datetime.datetime.now()))
            self.driver.quit()

