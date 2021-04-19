from Pages.tabs.logsTab import LogsTab
from Pages.tabs.settingsTab import SettingsTab
from tests.configfile_browserstack import EnvironmentSetupBrowserstack
from tests.configfile import EnvironmentSetup
from tests.configfile_browserstack_jenkins import EnvironmentSetupJenkins
from utilities.teststatus import TestStatus




class SettingsTabTest(EnvironmentSetupBrowserstack):

    def test_SettingsTab(self):
        self.st = SettingsTab(self.driver)
        self.st.SettingsTab()
        self.ts = TestStatus(self.driver)
