import time

import selenium
import pytest
import os
import unittest
from selenium import webdriver
import datetime
from appium import webdriver
#from appium.webdriver import webdriver
from Pages.home.login_page import LoginPage
from tests.configfile_browserstack_jenkins import EnvironmentSetupJenkins
from utilities.teststatus import TestStatus
from tests.configfile_browserstack import EnvironmentSetupBrowserstack
from tests.configfile import EnvironmentSetup

class LoginTests(EnvironmentSetupJenkins):

    @pytest.mark.tryfirst
    def test_validLogin(self):
        self.lp = LoginPage(self.driver)
        #self.lp.login("535cc_Room_300@avecare.com", "123456")
        self.lp.login("room100_littlemonkey@gmail.com", "Spiria123")
        time.sleep(10)
        result = self.lp.verifyLoginSuccessful()
        assert result == True
        self.ts = TestStatus(self.driver)
        self.ts.mark(result, resultMessage="Test Passed")




# ff = LoginTests()
# ff.test_validLogin()


