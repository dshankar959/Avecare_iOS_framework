import unittest
import datetime
from selenium import webdriver
from appium import webdriver
from Pages.home.login_page import LoginPage

class EnvironmentSetup(unittest.TestCase):


    def setUp(self):
        print("Running one time setUp at: "+str(datetime.datetime.now()))
        self.desired_caps = {}
        self.desired_caps['platformName'] = 'iOS'
        self.desired_caps['platformVersion'] = '14.1'
        self.desired_caps['automationName'] = 'XCUITest'
        self.desired_caps['deviceName'] = 'iPad Air (4th generation)'
        self.desired_caps['orientation'] = 'PORTRAIT'
        #self.desired_caps['fullReset'] = 'true'
        self.desired_caps['newCommandTimeout'] = '1000'
        self.desired_caps['autoGrantPermissions'] = 'true'
        self.desired_caps['permissions, photos'] = 'YES'
        #self.desired_caps['autoDismissAlerts'] = 'true'
        #self.desired_caps['autoAcceptAlerts'] = 'true'
        #self.desired_caps['permissions', 'microphone'] = 'NO'
        # self.desired_caps['app'] = '//Users//qa//Desktop//Avecare//educator.app'
        self.desired_caps[
            'app'] = '/Users/qa/Library/Developer/Xcode/DerivedData/Avecare-fxznavruviutgicofcbdmdvurqzh/Build/Products/Debug(QA)-iphonesimulator/educator.app'
        self.driver = webdriver.Remote('http://localhost:4724/wd/hub', self.desired_caps)
        self.driver.implicitly_wait(6000)

        lp = LoginPage(self.driver)
        lp.login("room100_littlemonkey@gmail.com", "Spiria123")


    def tearDown(self):
        if (self.driver != None):
            print("-------------------------------------------")
            print("Run Completed at : " + str(datetime.datetime.now()))
            self.driver.quit()


# if name == 'main':
#     unittest.main()