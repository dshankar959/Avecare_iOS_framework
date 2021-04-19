from Pages.tabs.logsTab import LogsTab
from Pages.tabs.notificationTab import NotificationTab
from tests.configfile import EnvironmentSetup
from tests.configfile_browserstack_jenkins import EnvironmentSetupJenkins
from tests.configfile_browserstack import EnvironmentSetupBrowserstack
from utilities.teststatus import TestStatus


class NotificationTabTest(EnvironmentSetupBrowserstack):

    def test_NotificationTab(self):
        self.nt = NotificationTab(self.driver)
        self.nt.notifications()
        # self.nt.dailychecklist()
        # self.nt.inspectionanddrills()
        # self.nt.injuryreport()
        # self.nt.reminders()
        # self.ts = TestStatus(self.driver)
