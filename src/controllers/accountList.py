"""
작성자 : 외기러기
최초 작성 시작 : 2024-05-03
최근 작성 완료 : 2026-06-11
내가 만든 이 코드를 당신 또는 다른사람이 먼저 만들었다고 거짓말하지 마세요!!
"""


from random import choice
from kivy.uix.textinput import TextInput
from kivy.uix.screenmanager import Screen

from models.account import Account


# 비밀번호 자동생성 및 관리하는 클래스
class AccountList(Screen):
    name = 'accountList'
    accountModel = Account()

    # 새로운 칸을 그린다
    def __newTextInput(self, num, key, value):
        newTextInput = TextInput(text=value, multiline=True)
        newTextInput.num = num
        newTextInput.key = key
        newTextInput.bind(focus=self.saveAccountList)
        return newTextInput

    # 빈 행을 새로 생성한다
    def createAccount(self, **kwargs):
        self.accountModel.createAccount()
        self.loadAccountList()

    # 클릭한 행을 삭제한다
    def deleteAccount(self, **kwargs):
        for widget in self.ids.accountList.children:
            if not isinstance(widget, TextInput):
                continue

            if widget.focus:
                self.accountModel.deleteAccount(num=widget.num)
                self.loadAccountList()
                break

    # 계정 목록을 불러온다
    def loadAccountList(self, **kwargs):
        self.ids.accountList.clear_widgets()

        for row in self.accountModel.loadAccountList():
            num = row.pop('num')
            for key, value in row.items():
                self.ids.accountList.add_widget(self.__newTextInput(num=num, key=key, value=value))

    # 입력이 끝난 행을 저장한다
    def saveAccountList(self, instance, focused, **kwargs):
        if focused:
            return

        # 포커스된 위젯의 num, key, value를 가져와 저장
        num = instance.num
        key = instance.key
        value = instance.text

        self.accountModel.saveAccountList(num=num, key=key, value=value)

    # 랜덤한 비밀번호를 생성한다
    def generatePassword(self, **kwargs):
        candidates = self.manager.get_screen('pswdSettings').getCandidates()
        length = self.manager.get_screen('pswdSettings').getLength()
        password = ''.join(choice(candidates) for _ in range(length))

        # 포커스된 위젯을 찾아 그 행의 비밀번호 생성
        pswd = None
        num = None
        for widget in self.ids.accountList.children:
            if not isinstance(widget, TextInput):
                continue

            if widget.key == 'pswd':
                pswd = widget
            if widget.focus:
                num = widget.num
            
            if pswd is not None and num is not None and pswd.num == num:
                pswd.text = password
                self.accountModel.saveAccountList(num=num, key=pswd.key, value=pswd.text)
                break
