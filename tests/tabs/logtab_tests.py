from tests.configfile_browserstack import EnvironmentSetupBrowserstack
from tests.configfile_browserstack_jenkins import EnvironmentSetupJenkins
from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus
from Pages.tabs.logsTab import LogsTab

class LogTabTest(EnvironmentSetupJenkins):

    def test_LogTab(self):
        self.lt = LogsTab(self.driver)
        self.ts = TestStatus(self.driver)
        self.lt.totalkids()
        #self.lt.prepare_child_log()
        #self.ts.markFinal(result1, "Log tab Verification")
