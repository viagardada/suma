@echo off
cd /d D:\workforce\project\suma
python -c "exec(open('suma/_analyze_times.py','r',encoding='utf-8').read())" > suma/_analyze_times_output.txt 2>&1
type suma\_analyze_times_output.txt