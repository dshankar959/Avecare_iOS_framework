from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus
from Pages.tabs.logsTab import LogsTab

class LogTabTest(EnvironmentSetup):

    def test_LogTab(self):
        self.lt = LogsTab(self.driver)
        self.ts = TestStatus(self.driver)
        self.lt.totalkids()
        #self.lt.prepare_child_log()
        #self.ts.markFinal(result1, "Log tab Verification")
