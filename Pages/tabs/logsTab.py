import datetime
import time
from datetime import date
from curses.ascii import TAB

from selenium.webdriver.common.keys import Keys

import utilities.custom_logger as cl
import logging
from base.basepage import BasePage
from utilities.scrolling import Scrolling

class LogsTab(BasePage):

    log = cl.customLogger(logging.INFO)


    def __init__(self, driver):
        super().__init__(driver)
        self.driver = driver

     #### Locators  ####

    _plus_icon = "//XCUIElementTypeButton[@name='plus icon']"
    _logs_tab = "//XCUIElementTypeButton[@name='Logs']"
    _settings_tab = "//XCUIElementTypeButton[@name='Settings']"
    _last_name_tab = "//XCUIElementTypeButton[@name='Last Name']"
    _table_list = ("//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeTable")
    _children_list = ("//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeTable/XCUIElementTypeCell")
    _child_one = ("//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeTable/XCUIElementTypeCell[3]")
    _snack1 = "(//XCUIElementTypeButton[@name='1-2'])[1]"
    _lunch = "(//XCUIElementTypeButton[@name='3-4'])[2]"
    _snack2 = "(//XCUIElementTypeButton[@name='5-6'])[3]"
    _rest = "//XCUIElementTypeStaticText[@name='12:00PM - 1:00PM']"
    _child_emotion = "//XCUIElementTypeStaticText[@name='Select Emotion']"
    _select_all = "//XCUIElementTypeButton[@name='Select All']"
    _child_emotion_happy = "(//XCUIElementTypeImage[@name='checkmark_off])[1]"
    _child_emotion_sad = "(//XCUIElementTypeImage[@name='checkmark_off'])[2]"
    _child_emotion_excited = "(//XCUIElementTypeImage[@name='checkmark_off'])[3]"
    _emotion_done_button = "//XCUIElementTypeButton[@name='Done']"

    _rest_time_done = "//XCUIElementTypeButton[@name='Done']"
    _educator_note = "(//XCUIElementTypeStaticText[@name='140 characters maximum.'])"
    _bathroom1_wet = "(//XCUIElementTypeButton[@name='Wet'])[1]"
    _bathroom2_dry = "(//XCUIElementTypeButton[@name='Dry'])[2]"
    _bathroom3_bm = "(//XCUIElementTypeButton[@name='BM'])[3]"
    _bathroom4_toilet = "(//XCUIElementTypeButton[@name='Toilet'])[4]"
    _select_picture = "//XCUIElementTypeImage[@name='camera-plus']"
    _add_caption = "(//XCUIElementTypeStaticText[@name='140 characters maximum.'])[2]"
    _add_row = "//XCUIElementTypeButton[@name='plus icon']"
    _publish_button = "//XCUIElementTypeStaticText[@name='Publish']"
    _published_checkmark = "(//XCUIElementTypeButton[@name='checkmark'])"
    #_scroll_point = "//XCUIElementTypeOther[@name='Vertical scroll bar, 2 pages']"
    _scroll_point = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeOther/XCUIElementTypeScrollView/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther[8]/XCUIElementTypeOther/XCUIElementTypeOther[3]"
    _caption = "Caption"
    #_camera_button = "//XCUIElementTypeImage[@name='camera-plus']"
    _camera_button = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeOther/XCUIElementTypeScrollView/XCUIElementTypeOther[1]/XCUIElementTypeOther/XCUIElementTypeOther[24]/XCUIElementTypeOther/XCUIElementTypeOther[2]/XCUIElementTypeImage[1]"
    _picker_hour = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeDatePicker/XCUIElementTypePicker/XCUIElementTypePickerWheel[1]"
    _picker_minute = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeDatePicker/XCUIElementTypePicker/XCUIElementTypePickerWheel[2]"
    _picker_ampm = "//XCUIElementTypeApplication[@name='Daily Wonders']/XCUIElementTypeWindow[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther[3]/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeOther/XCUIElementTypeDatePicker/XCUIElementTypePicker/XCUIElementTypePickerWheel[3]"
    _picker_date = "//XCUIElementTypePickerWheel"
    _photo_access_Ok_button = "//XCUIElementTypeButton[@name='OK']"
    _first_photo = "//XCUIElementTypeCell[@name='Photo 3']"
    _photo_add_done_button = "//XCUIElementTypeButton[@name='Done (1)']"
    _photo_crap_done_button = "//XCUIElementTypeButton[@name='Done']"


    def prepare_child_log(self):
        total_children = self.getElementList(self._children_list, locatorType="xpath")
        print("The total number of children in this Room =", + len(total_children))

        for child in range(len(total_children)):
            print("Child #", child)
            children = total_children[child]
            print(children)
            time.sleep(2)
            children.click()
            time.sleep(3)
            self.elementClick(self._snack1, locatorType="xpath")
            self.elementClick(self._lunch, locatorType="xpath")
            self.elementClick(self._snack2, locatorType="xpath")
            self.elementClick(self._rest, locatorType="xpath")
            self.elementClick(self._logs_tab, locatorType="xpath")

            # Set rest time by selecting picker
            time.sleep(2)
            picker = self.getElementList(self._picker_date, locatorType="xpath")
            for date in picker:
                print(date.text)
                date.send_keys("10")
                date.send_keys(Keys.TAB)

                date.send_keys("30")
                date.send_keys(Keys.TAB)

                date.send_keys("AM")
                date.send_keys(Keys.TAB)
            self.elementClick(self._rest_time_done, locatorType="xpath")
            self.elementClick(self._child_emotion, locatorType="xpath")
            self.elementClick(self._select_all, locatorType="xpath")
            self.elementClick(self._emotion_done_button, locatorType="xpath")
            self.elementClick(self._educator_note, locatorType="xpath")
            time.sleep(2)
            ## get current date and time
            currentdate = datetime.datetime.today()
            self.sendKeys(currentdate, self._educator_note, locatorType="xpath")
            self.driver.hide_keyboard()
            self.elementClick(self._bathroom1_wet, locatorType="xpath")
            self.elementClick(self._bathroom2_dry, locatorType="xpath")
            self.elementClick(self._bathroom3_bm, locatorType="xpath")
            self.elementClick(self._bathroom4_toilet, locatorType="xpath")
            time.sleep(2)

            self.log.info("Before scrolling")
            self.elementClick(self._scroll_point, locatorType="xpath")
            #scroll_element = self.getElement(self._caption, locatorType="accessibility")
            tc = Scrolling(self.driver)
            #tc.scroll_to_element(self)
            tc.scroll_to_element(self, direction="up", click=False)
            time.sleep(5)

            # #### Select photo and add ####
            self.elementClick(self._camera_button, locatorType="xpath")
            if self.isElementDisplayed(self._photo_access_Ok_button, locatorType="xpath"):
                self.elementClick(self._photo_access_Ok_button, locatorType="xpath")
            else:
                print("There is dialog present")

            self.elementClick(self._first_photo, locatorType="xpath")

            self.elementClick(self._photo_add_done_button, locatorType="xpath")
            self.elementClick(self._photo_crap_done_button, locatorType="xpath")

            self.screenShot("passed")
            self.elementClick(self._publish_button, locatorType="xpath")
            time.sleep(2)
            tc.scroll_to_element(self, direction="down", click=False)
            time.sleep(5)
            total_children = self.getElementList(self._children_list, locatorType="xpath")

    def totalkids(self):
        self.prepare_child_log()
        print("Logs have been filled")