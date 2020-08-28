from Pages.tabs.logsTab import LogsTab
from Pages.tabs.documentationTab import DocumentationTab
from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus


class DocumentationTabTest(EnvironmentSetup):

    def test_NotificationTab(self):
        self.dt = DocumentationTab(self.driver)
        self.dt.DocumentTab()

        self.ts = TestStatus(self.driver)