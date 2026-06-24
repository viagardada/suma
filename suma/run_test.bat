@echo off
cd /d D:\workforce\project\suma
python -c "exec(open('suma/_test_conversion.py','r',encoding='utf-8').read())"
type suma\_test_conversion_output.txt