from Pages.tabs.logsTab import LogsTab
from Pages.tabs.settingsTab import SettingsTab
from tests.browserstackconfig import EnvironmentSetuptest
from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus



class SettingsTabTest(EnvironmentSetuptest):

    def test_SettingsTab(self):
        self.st = SettingsTab(self.driver)
        self.st.SettingsTab()
        self.ts = TestStatus(self.driver)
