from Pages.tabs.logsTab import LogsTab
from Pages.tabs.settingsTab import SettingsTab
from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus



class SettingsTabTest(EnvironmentSetup):

    def test_SettingsTab(self):
        self.st = SettingsTab(self.driver)
        self.st.SettingsTab()
        self.ts = TestStatus(self.driver)
