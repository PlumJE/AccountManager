"""
작성자 : 외기러기
최초 작성 시작 : 2024-05-03
최근 작성 완료 : 2026-06-11
내가 만든 이 코드를 당신 또는 다른사람이 먼저 만들었다고 거짓말하지 마세요!!
"""


from pathlib import Path
from sqlite3 import connect
from kivy.app import App


# 계정 정보를 다루는 모델
class Account:
    # 데이터베이스 파일 경로
    def __getDBFilePath(self):
        dbDirPath = Path(App.get_running_app().user_data_dir)
        if not dbDirPath.exists():
            dbDirPath.mkdir(parents=True, exist_ok=True)

        dbFilePath = Path(dbDirPath, 'accountList.sqlite3')
        with connect(dbFilePath) as connection:
            cursor = connection.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS accountList (
                    num INTEGER PRIMARY KEY,
                    addr TEXT NOT NULL,
                    id TEXT,
                    pswd TEXT
                )
            """)
            connection.commit()

        return dbFilePath

    # 빈 계정을 새로 생성한다
    def createAccount(self):
        with connect(self.__getDBFilePath()) as connection:
            cursor = connection.cursor()
            cursor.execute(f"SELECT MAX(num) FROM accountList")
            fetch = cursor.fetchone()
            newNum = fetch[0] + 1 if fetch[0] is not None else 0

            cursor.execute(f"INSERT INTO accountList (num, addr, id, pswd) VALUES ({newNum}, '', '', '')")
            connection.commit()

    # 계정을 삭제한다
    def deleteAccount(self, num):
        with connect(self.__getDBFilePath()) as connection:
            cursor = connection.cursor()
            cursor.execute(f"DELETE FROM accountList WHERE num={num}")
            connection.commit()

    # 계정 목록을 불러온다
    def loadAccountList(self):
        with connect(self.__getDBFilePath()) as connection:
            cursor = connection.cursor()
            cursor.execute(f"SELECT num, addr, id, pswd FROM accountList ORDER BY num")
            fetch = cursor.fetchall()
        
        return [{'num': row[0], 'addr': row[1], 'id': row[2], 'pswd': row[3]} for row in fetch]

    # 입력이 끝난 계정을 저장한다
    def saveAccountList(self, num, key, value):
        with connect(self.__getDBFilePath()) as connection:
            cursor = connection.cursor()
            cursor.execute(f"UPDATE accountList SET {key}='{value}' WHERE num={num}")
            connection.commit()