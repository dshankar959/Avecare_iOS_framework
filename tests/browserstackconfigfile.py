import datetime

from _pytest import unittest
from appium import webdriver
from appium.webdriver.common.mobileby import MobileBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from Pages.home.login_page import LoginPage

desired_cap = {
# Set your access credentials
"browserstack.user": "torontoqaspiriac1",
"browserstack.key": "pmxn6rnEczeHs4cSxEzb",

# Set URL of the application under test
"app_url":"bs://7c49467808f0d461092bfe6b06ee882505cb66d3",

# Specify device and os_version for testing
"device": "iPad 7th",
"os_version": "13",

# Set other BrowserStack capabilities
"project": "Avecare-Educator",
"build": "Python iOS",
"name": "first_test"
}

# Initialize the remote Webdriver using BrowserStack remote URL
# and desired capabilities defined above
driver = webdriver.Remote(
    command_executor="http://hub-cloud.browserstack.com/wd/hub",
    desired_capabilities=desired_cap
)

# Write your custom code here
# lp = LoginPage(driver)
# #lp.login("535cc_Room_300@avecare.com", "123456")
# lp.login("room100_littlemonkey@gmail.com", "Spiria123")

# def tearDown(self):
#     if (self.driver != None):
#         print("-------------------------------------------")
#         print("Run Completed at : " + str(datetime.datetime.now()))
#         self.driver.quit()
#     # Invoke driver.quit() after the test is done to indicate that the test is completed.
driver.quit()