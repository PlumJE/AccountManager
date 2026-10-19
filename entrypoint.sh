#!/bin/bash

# VNC 비밀번호 자동 생성 (환경변수 VNC_PASSWD가 설정되어 있으면 해당 값 사용, 없으면 '0000')
x11vnc -storepasswd "${VNC_PASSWD:-0000}" "$HOME/.vnc/passwd"

# Xvfb 가상 디스플레이 시작
export DISPLAY=:0
if ! pgrep -x Xvfb >/dev/null; then
    Xvfb :0 -screen 0 1280x800x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
    sleep 1
fi

# x11vnc 서버 시작
pkill -x x11vnc 2>/dev/null || true
x11vnc -display :0 -rfbauth "$HOME/.vnc/passwd" -forever -shared -rfbport 5900 -listen 0.0.0.0 >/tmp/x11vnc.log 2>&1 &

# 전달된 CMD (예: /bin/bash) 실행
exec "$@"
