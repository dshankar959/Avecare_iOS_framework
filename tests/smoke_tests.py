import unittest
from tests.home.login_tests import LoginTests
from tests.tabs.logtab_tests import LogTabTest
from tests.tabs.notificationtab_tests import NotificationTabTest
from tests.tabs.documentationtab_tests import DocumentationTabTest
from tests.tabs.settingstab_tests import SettingsTabTest

### Get all tests from the test classes
#tc1 = unittest.TestLoader().loadTestsFromTestCase(LoginTests)
#tc1 = unittest.TestLoader().loadTestsFromTestCase(LogTabTest)
tc2 = unittest.TestLoader().loadTestsFromTestCase(NotificationTabTest)
tc3 = unittest.TestLoader().loadTestsFromTestCase(DocumentationTabTest)
tc4 = unittest.TestLoader().loadTestsFromTestCase(SettingsTabTest)

### Creat a test suite combining all test classes
smoketest = unittest.TestSuite([tc2, tc3, tc4])

unittest.TextTestRunner(verbosity=2).run(smoketest)
