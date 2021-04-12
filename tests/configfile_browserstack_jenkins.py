import datetime
import os
import unittest

from appium import webdriver

from Pages.home.login_page import LoginPage

user_name = os.getenv("BROWSERSTACK_USERNAME")
access_key = os.getenv("BROWSERSTACK_ACCESS_KEY")
build_name = os.getenv("BROWSERSTACK_BUILD_NAME")
browserstack_local = os.getenv("BROWSERSTACK_LOCAL")
browserstack_local_identifier = os.getenv("BROWSERSTACK_LOCAL_IDENTIFIER")
#app = os.getenv("BROWSERSTACK_APP_ID")
#app_url = "bs://111cabd70b47356120be9185dfd0af976e9f52f1"


class EnvironmentSetupJenkins(unittest.TestCase):

    def setUp(self):
        print("Running one time setUp at: "+str(datetime.datetime.now()))
        desired_cap = {
        "app": "bs://111cabd70b47356120be9185dfd0af976e9f52f1",
        'device': 'iPad 8th',
        'os_version': "14",
        'name': 'BStack-[Jenkins] iOSEducator app',  # test name
        'build': "Python iOS Browserstack and Jenkins",  # CI/CD job name using BROWSERSTACK_BUILD_NAME env variable

        # 'browserstack.local': browserstack_local,
        # 'browserstack.localIdentifier': browserstack_local_identifier

        # Set your access credentials
        "browserstack.user": "gatineauqa1",
        "browserstack.key": "VAn9nnjDxxsshxN4WRNt",

        ## Using devikar69@gmail.com credentials
        # "browserstack.user": "dferrari2",
        # "browserstack.key": "c9z8dL3Qk4XqR8y3zMkP",

         # 'browserstack.user': user_name,
         # 'browserstack.key': access_key,

        # Set other BrowserStack capabilities
        "project": "Avecare-Educator",
        # "build": "Python iOS Browserstack and Jenkins",
        # "name": "first_test"
        }

        # self.driver = webdriver.Remote("https://"+user_name+":"+access_key+"@hub-cloud.browserstack.com/wd/hub",
        #                                desired_cap)

        self.driver = webdriver.Remote(
            command_executor='https://hub-cloud.browserstack.com/wd/hub',
            desired_capabilities=desired_cap)

        self.driver.implicitly_wait(6000)

        # Write your custom code here
        lp = LoginPage(self.driver)
        # lp.login("535cc_Room_300@avecare.com", "123456")
        lp.login("room100_littlemonkey@gmail.com", "Spiria123")

    def tearDown(self):
        if (self.driver != None):
            print("-------------------------------------------")
            print("Run Completed at : " + str(datetime.datetime.now()))
            self.driver.quit()