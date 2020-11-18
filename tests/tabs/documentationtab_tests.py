from Pages.tabs.logsTab import LogsTab
from Pages.tabs.documentationTab import DocumentationTab
from tests.configfile import EnvironmentSetup
from tests.configfile_browserstack_jenkins import EnvironmentSetupJenkins
from tests.configfile_browserstack import EnvironmentSetupBrowserstack
from utilities.teststatus import TestStatus


class DocumentationTabTest(EnvironmentSetupJenkins):

    def test_DocummentationTab(self):
        self.dt = DocumentationTab(self.driver)
        self.dt.DocumentTab()

        self.ts = TestStatus(self.driver)