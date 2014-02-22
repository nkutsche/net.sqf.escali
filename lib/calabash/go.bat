set INPUT=%1
set CONFIG=%2
set TYPE=%3

java -cp "calabash.jar; lib/" com.xmlcalabash.drivers.Main --input config=%CONFIG% ..\..\Scripts\%TYPE%\xproc\dev\%TYPE%.xpl source=%INPUT%