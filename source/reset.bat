FOR /f "tokens=*" %%i IN ('docker ps -a -q') DO docker stop %%i
FOR /f "tokens=*" %%i IN ('docker ps -a -q') DO docker rm %%i