@echo off
git config --get-regexp "^alias\." | findstr /R /C:"^alias\."