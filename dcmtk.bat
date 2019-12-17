::====================================> About the Script <===========================================::
::SCRIPT  : dcmtk.bat: Send Only Dicom files.
::AUTOR   : Luan A. Loose
::DATA    : 22/02/2019
::=========================================> Versions <==============================================::
:::: Versao 4.0 | Luan A. Loose | 27/06/2019
::- Le qualquer estrutura de pasta.
::- Envia apenas arquivos DICOM, os nao DICOM sao ignorados.
::- Faz backup.
::- Funciona o arrastar e enviar.
::- Nomes com espacos sao lidos.
::==========================================> Begin <================================================::
:: Environment path
set PATH=%PATH%;C:\Windows\SysWOW64;C:\Windows\System32
::===================================================================================================::
:: Configurable variables
set aetitle_local="<%aetitle_local%>"
set aetitle_dest="<%aetitle_dest%>"
set ddns="<%ddns%>"
set port="<%port%>"
set path_dcm="<%path_dcm%>storescu"
set path_dropfiles="<%path_dropfiles%>"
set path_study="<%path_study%>"
set path_backup="<%path_backup%>"
set path_robocopy="<%path_robocopy%>"
::===================================================================================================::
:: Loop for capture the IP
for /f "tokens=2 delims=[]" %%a in ('ping -n 1 %ddns%') do set ip=%%a

::===================================================================================================::
:: Check if path is created
IF NOT EXIST %path_study% md %path_study%

:: Check if path is empty
for /f %%a in ('dir /b /s /aa %path_study%^|find /c /v "" ') do set QUANT1=%%a

:: Case yes delete all the content
IF %QUANT1% GTR 0 (

  forfiles /P %path_study% /M * /C "cmd /c if @isdir==TRUE rmdir /S /Q @file" & del %path_study% /q
 
  ) 

::===================================================================================================::
:: Move the content
:COPY
%path_robocopy% %path_dropfiles% %path_study% /a /s /MOV

::===================================================================================================::
:: time command
timeout /T 5

:: Set to QUANT how much files
for /f %%a in ('dir /b /s /aa %path_dropfiles%^|find /c /v "" ') do set QUANT2=%%a

:: Test if path is empty
IF %QUANT2% GTR 0 (

  GOTO :COPY
 
  ) ELSE (

::: Remove the empty folders and content of folder
    forfiles /P %path_dropfiles% /M * /C "cmd /c if @isdir==TRUE rmdir /S /Q @file" & del %path_dropfiles% /q
            
::: Go to send line code
    GOTO :SEND
    
  )

::===================================================================================================::
:: Send the files
:SEND
for /R %path_study% %%i IN (*.*) DO (

  %path_dcm% -v -xv -to 120 +sd -aec %aetitle_dest% -aet %aetitle_local% %ip% %port% "%%i"

  )

:: Move to path_backup
%path_robocopy% %path_study% %path_backup% /a /s /MOV

:: Remove the empty folders
forfiles /P %path_study% /M * /C "cmd /c if @isdir==TRUE rmdir /S /Q @file"

::===========================================> END <=================================================::