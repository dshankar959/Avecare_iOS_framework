from Pages.tabs.logsTab import LogsTab
from Pages.tabs.notificationTab import NotificationTab
from tests.configfile import EnvironmentSetup
from utilities.teststatus import TestStatus


class NotificationTabTest(EnvironmentSetup):

    def test_NotificationTab(self):
        self.nt = NotificationTab(self.driver)
        self.nt.dailychecklist()
        self.nt.inspectionanddrills()
        self.nt.injuryreport()
        self.nt.reminders()
        self.ts = TestStatus(self.driver)
