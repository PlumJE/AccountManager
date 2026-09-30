"""
작성자 : 외기러기
최초 작성 시작 : 2024-05-03
최근 작성 완료 : 2026-06-11
내가 만든 이 코드를 당신 또는 다른사람이 먼저 만들었다고 거짓말하지 마세요!!
"""


from pathlib import Path


# 루트 폴더 경로
def rootPath():
    return str(Path(__file__).resolve().parent.parent)
