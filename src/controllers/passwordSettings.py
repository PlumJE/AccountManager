"""
작성자 : 외기러기
최초 작성 시작 : 2024-05-03
최근 작성 완료 : 2026-06-11
내가 만든 이 코드를 당신 또는 다른사람이 먼저 만들었다고 거짓말하지 마세요!!
"""


from kivy.uix.label import Label
from kivy.uix.popup import Popup
from kivy.uix.screenmanager import Screen


# 비밀번호 자동생성 설정하는 클래스
class PasswordSettings(Screen):
    name = 'pswdSettings'
    __candidates = ''
    __length = 0

    # 반드시 추가할 문자들을 설정
    def __includeCandidates(self):
        includes = ''
        if self.ids.upperToggle.state == 'down':
            includes += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        if self.ids.lowerToggle.state == 'down':
            includes += 'abcdefghijklmnopqrstuvwxyz'
        if self.ids.numberToggle.state == 'down':
            includes += '0123456789'
        if self.ids.specialToggle.state == 'down':
            includes += '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
        
        return includes
    
    # 반드시 제외할 문자들을 설정
    def __excludeCandidates(self, candidates):
        excludes = self.ids.excludeTextInput.text
        for e in excludes:
            candidates = candidates.replace(e, '')
        
        return candidates

    # 비밀번호 길이를 설정
    def __setLength(self):
        length = self.ids.lengthTextInput.text
        if not length.isnumeric():
            return 0

        length = int(length)
        if length < 0:
            return 0
        
        return length

    # 후보 문자들을 출력
    def getCandidates(self):
        return self.__candidates

    # 비밀번호 길이를 출력
    def getLength(self):
        return self.__length

    # 설정을 초기화한다. 초기화값은 개발자가 임의 유효값으로 지정
    def initSettings(self, **kwargs):
        self.__candidates = self.__includeCandidates()
        self.__candidates = self.__excludeCandidates(self.__candidates)
        self.__length = self.__setLength()

    # 설정을 저장하고 돌아간다
    def saveSettings(self, **kwargs):
        pswd_candidates = self.__includeCandidates()
        if pswd_candidates == None:
            Popup(title='오류!', content=Label(text="올바른 필수문자를 입력하세요.."), size_hint = (1, 0.2), auto_dismiss = True).open()
            return
        
        pswd_candidates = self.__excludeCandidates(pswd_candidates)
        if pswd_candidates == None:
            Popup(title='오류!', content=Label(text="올바른 제외문자를 입력하세요."), size_hint = (1, 0.2), auto_dismiss = True).open()
            return

        length = self.__setLength()
        if length == None:
            Popup(title='오류!', content=Label(text="올바른 숫자를 입력하세요."), size_hint = (1, 0.2), auto_dismiss = True).open()
            return
        
        self.__candidates = pswd_candidates
        self.__length = length

        self.manager.current = 'accountList'
