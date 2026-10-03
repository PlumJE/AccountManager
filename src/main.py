"""
작성자 : 외기러기
최초 작성 시작 : 2024-05-03
최근 작성 완료 : 2026-06-11
내가 만든 이 코드를 당신 또는 다른사람이 먼저 만들었다고 거짓말하지 마세요!!
"""


from traceback import format_exc
from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager
from kivy.core.window import Window
from kivy.core.text import LabelBase

import sys
from pathlib import Path

source_path = Path(__file__).resolve().parent
sys.path.insert(0, str(source_path / 'controllers'))
sys.path.insert(0, str(source_path))

from controllers.etcetera import rootPath
from controllers.accountList import AccountList
from controllers.passwordSettings import PasswordSettings
from controllers.logger import logger


# 앱 전체를 나타내는 클래스
class PswdMakerApp(App):
    # 앱을 그린다
    def build(self):
        Window.size = (1000, 2000)
        LabelBase.register(name='Nanum', fn_regular=rootPath() + '/resources/fonts/NANUMGOTHIC.TTF')

        Builder.load_file(rootPath() + '/views/AccountList.kv')
        Builder.load_file(rootPath() + '/views/PasswordSettings.kv')

        self.__accountListScreen = AccountList()
        self.__pswdSettingsScreen = PasswordSettings()

        self.__mainScreen = ScreenManager()
        self.__mainScreen.add_widget(self.__accountListScreen)
        self.__mainScreen.add_widget(self.__pswdSettingsScreen)

        return self.__mainScreen


if __name__ == '__main__':
    try:
        PswdMakerApp().run()
    except:
        logger.critical(format_exc())