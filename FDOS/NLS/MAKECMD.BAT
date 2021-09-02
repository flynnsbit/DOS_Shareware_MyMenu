@echo off
del command.com
if exist cmd-%lang%.com ren cmd-%lang%.com command.com
del cmd-*.com
