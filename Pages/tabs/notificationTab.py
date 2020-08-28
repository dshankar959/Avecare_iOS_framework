import time

from appium.webdriver.common.touch_action import TouchAction
from selenium.webdriver.common.keys import Keys

import utilities.custom_logger as cl
import logging
from base.basepage import BasePage
from utilities.scrolling import Scrolling

class NotificationTab(BasePage):

    log = cl.customLogger(logging.INFO)

    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver

    #Locators
    ############################## DAILY CHECKLIST ###################
    _notification_tab = "//XCUIElementTypeButton[@name='Notifications']"
    _check_playground = "//XCUIElementTypeButton[@name='Check the playground']"
    _check_toiletpaper = "//XCUIElementTypeButton[@name='Check the toilet papers']"
    _daily_log = "//XCUIElementTypeButton[@name='Daily log']"
    _signed_inout = "//XCUIElementTypeButton[@name='Check children in and out']"
    _complete_button = "//XCUIElementTypeButton[@name='Complete']"

    #################################### INSPECTIONS AND DRILLS ####################################################

    _inspection_drills = "//XCUIElementTypeStaticText[@name='Inspections and Drills']"
    _ok_button = "//XCUIElementTypeButton[@name='OK']"
    _form_dropdown_icon = "//XCUIElementTypeImage[@name='form-dropdown-icon']"
    _select_activity = "//XCUIElementTypeStaticText[@name='No activity selected']"
    #_calender_button = "//XCUIElementTypeImage[@name='form-calendar-icon']"
    _calender_button = "//XCUIElementTypeStaticText[@name='YY / MM / DD']"
    _activities = "//XCUIElementTypePickerWheel"
    _select_date_1 = "//XCUIElementTypePicker"
    _done_button = "//XCUIElementTypeButton[@name='Done']"
    #_done_button = "//*[contains(@name='Done')]"
    _special_instruction = "//XCUIElementTypeTextView"
    _send_button = "//XCUIElementTypeButton[@name='Send']"

    ########################### INJURY REPORT ##############################

    _injury_report = "//XCUIElementTypeStaticText[@name='Injury Report']"
    _add_child = "//XCUIElementTypeStaticText[@name='Add a child']"
    _add_second_child = "(//XCUIElementTypeImage[@name='checkmark_off'])[2]"
    _add_fifth_child = "(//XCUIElementTypeImage[@name='checkmark_off'])[5]"
    _injury_type = "//XCUIElementTypeStaticText[@name='Select injury type']"
    _picker_date = "//XCUIElementTypePickerWheel"
    _done_button_addchild = "//XCUIElementTypeStaticText[@name='Done']"

    ################################# REMINDERS ########################################
    _reminder = "//XCUIElementTypeStaticText[@name='Reminders']"
    _add_child_injury = "//XCUIElementTypeStaticText[@name='Add a schild']"
    _select_all = "//XCUIElementTypeButton[@name='Select All']"
    _select_reminder = "//XCUIElementTypeStaticText[@name='No reminder selected.']"
    _additional_info = "//XCUIElementTypeTextView"



    def DailyChecklist(self):
        #### Daily Checklist Publish #####
        self.elementClick(self._notification_tab, locatorType="xpath")
        #self.elementClick(self._daily_healthcheck, locatorType="xpath")
        self.elementClick(self._daily_log, locatorType="xpath")
        self.elementClick(self._signed_inout, locatorType="xpath")
        self.elementClick(self._check_playground, locatorType="xpath")
        self.elementClick(self._check_toiletpaper, locatorType="xpath")
        time.sleep(3)
        self.elementClick(self._complete_button, locatorType="xpath")
        time.sleep(3)
        self.elementClick(self._ok_button, locatorType="xpath")
        time.sleep(3)

    def InspectionsDrills(self):
        touch = TouchAction(self.driver)
        self.elementClick(self._inspection_drills,locatorType="xpath")
        self.elementClick(self._select_activity, locatorType="xpath")
        current_activity = self.getElement(self._activities, locatorType="xpath")
        print(current_activity.get_attribute('value'))
        current_activity.send_keys("Lock down")
        #touch.tap(element=None, x=699, y=761, count=1).release().perform()
        self.elementClick(self._done_button, locatorType="xpath")
        time.sleep(2)
        self.sendKeys("Inspections and Drill testing", self._special_instruction, locatorType="xpath")
        time.sleep(2)
        self.driver.hide_keyboard()
        ## Select date
        self.elementClick(self._calender_button, locatorType="xpath")
        picker = self.getElementList(self._picker_date, locatorType="xpath")
        for date in picker:
            print(date.text)
            time.sleep(3)
            date.send_keys("September")
            date.send_keys(Keys.TAB)
            time.sleep(2)

            date.send_keys("30")
            date.send_keys(Keys.TAB)
            time.sleep(2)

            date.send_keys("2021")
            time.sleep(2)
            print(date.text)
            #touch.tap(element=None, x=699, y=761, count=1).release().perform()
            self.elementClick(self._done_button, locatorType="xpath")
            time.sleep(2)
            self.elementClick(self._send_button, locatorType="xpath")

    def InjuryReport(self):
        self.elementClick(self._injury_report, locatorType="xpath")
        self.elementClick(self._add_child, locatorType="xpath")
        # self.elementClick(self._add_second_child, locatorType="xpath")
        # self.elementClick(self._add_fifth_child, locatorType="xpath")
        self.elementClick(self._select_all, locatorType="xpath")
        self.elementClick(self._done_button_addchild, locatorType="xpath")
        self.elementClick(self._injury_type, locatorType="xpath")
        self.elementClick(self._done_button, locatorType="xpath")
        self.elementClick(self._send_button, locatorType="xpath")

    def Reminders(self):
        self.elementClick(self._reminder, locatorType="xpath")
        self.elementClick(self._add_child_injury, locatorType="xpath")
        self.elementClick(self._select_all, locatorType="xpath")
        self.elementClick(self._done_button_addchild, locatorType="xpath")
        self.sendKeys("Reminder test", self._additional_info, locatorType="xpath")
        self.driver.hide_keyboard()
        self.elementClick(self._select_reminder,locatorType="xpath")
        total_reminder = self.getElementList(self._picker_date, locatorType="xpath")
        for reminder in total_reminder:
            print(reminder.text)
            time.sleep(3)
            reminder.send_keys("Photo Day")
            reminder.send_keys(Keys.TAB)
            time.sleep(2)
        self.elementClick(self._done_button, locatorType="xpath")
        self.sendKeys("Reminder to test", self._additional_info, locatorType="xpath")
        self.elementClick(self._send_button,locatorType="xpath")


    def dailychecklist(self):
        self.DailyChecklist()
    def inspectionanddrills(self):
        self.InspectionsDrills()
    def injuryreport(self):
        self.InjuryReport()
    def reminders(self):
        self.Reminders()

