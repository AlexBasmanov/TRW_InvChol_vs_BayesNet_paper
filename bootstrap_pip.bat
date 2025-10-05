@echo off
setlocal enabledelayedexpansion
REM ---------------------------------------------------------------------
REM  bootstrap_pip.bat — simple Windows (cmd) bootstrap via pip
REM
REM  Usage:
REM    bootstrap_pip.bat [--no-venv] [--jupyter]
REM
REM  - By default, creates/uses .venv in the repo root and installs
REM    pinned dependencies listed below.
REM  - Use --no-venv to install into the current/global Python environment
REM    (not recommended).
REM  - Use --jupyter to also install JupyterLab + ipykernel.
REM
REM  Recommended Python: 3.11.x (e.g., 3.11.13)
REM  Note: prefers the Windows 'py -3.11' launcher when available.
REM ---------------------------------------------------------------------

set CREATE_VENV=1
set INSTALL_JUPYTER=0

:parse
if "%~1"=="" goto afterparse
if /I "%~1"=="--no-venv" set CREATE_VENV=0
if /I "%~1"=="--jupyter" set INSTALL_JUPYTER=1
shift
goto parse
:afterparse

REM Resolve script directory and go there
set SCRIPT_DIR=%~dp0
pushd "%SCRIPT_DIR%"

REM Choose Python executable (prefer py -3.11)
set "PY_EXE="
py -3.11 -c "import sys" >nul 2>&1
if %errorlevel%==0 (
  set "PY_EXE=py -3.11"
  echo [INFO] Using Python via 'py -3.11'
) else (
  where python >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] Python is not on PATH. Please install Python 3.11.x and try again.
    popd
    exit /b 1
  )
  for /f "usebackq tokens=2,* delims= " %%A in (`python -V 2^>^&1`) do (
    set "PY_VER=%%A"
  )
  echo [INFO] Using Python found on PATH: !PY_VER!
  set "PY_EXE=python"
)

REM Create a venv unless --no-venv was passed
if "%CREATE_VENV%"=="1" (
  if not exist ".venv\Scripts\activate.bat" (
    echo [INFO] Creating virtual environment in .venv ...
    %PY_EXE% -m venv .venv || ( echo [ERROR] Failed to create venv & popd & exit /b 1 )
  )
  call ".venv\Scripts\activate.bat"
)

REM Keep pip compatible with some legacy build flows
python -m pip install -q "pip<25.3" || ( echo [ERROR] pip upgrade failed & popd & exit /b 1 )

REM Base scientific stack (pinned)
echo [INFO] Installing base scientific stack...
python -m pip install -q --upgrade ^
  numpy==2.2.6 ^
  pandas==2.3.2 ^
  matplotlib==3.10.6 ^
  scipy==1.16.1 ^
  arch==7.2.0 ^
  joblib==1.5.2 ^
  openpyxl==3.1.5 ^
  xlrd==2.0.2 ^
  || ( echo [ERROR] Base stack install failed & popd & exit /b 1 )

REM py-banshee: wheel-first, then PEP517 fallback
echo [INFO] Installing py-banshee (wheel-first)...
python -m pip install -q --only-binary=:all: py-banshee==1.1.2
if errorlevel 1 (
  echo [WARN] Wheel not available, trying PEP517 build...
  python -m pip install -q --use-pep517 py-banshee==1.1.2 || ( echo [ERROR] py-banshee install failed & popd & exit /b 1 )
)

REM Optional JupyterLab
if "%INSTALL_JUPYTER%"=="1" (
  echo [INFO] Installing JupyterLab and ipykernel...
  python -m pip install -q "jupyterlab>=4,<5" "ipykernel>=6.29" || ( echo [ERROR] Jupyter install failed & popd & exit /b 1 )
)

REM Show versions (compact, safe)
echo.
python -c "import sys; print('Python:',sys.version.split()[0]); print('Kernel:',sys.executable)" 2>nul
python -c "import numpy,pandas,matplotlib,scipy,joblib,openpyxl,xlrd; print('[VERS] numpy=%s pandas=%s matplotlib=%s scipy=%s joblib=%s openpyxl=%s xlrd=%s' % (numpy.__version__,pandas.__version__,matplotlib.__version__,scipy.__version__,joblib.__version__,openpyxl.__version__,xlrd.__version__))" 2>nul
python -c "import importlib; m=importlib.util.find_spec('arch'); print('arch='+(__import__('arch').__version__ if m else 'n/a'))" 2>nul
python -c "import importlib; m=importlib.util.find_spec('py_banshee'); print('py-banshee='+(__import__('py_banshee').__version__ if m else 'not-installed'))" 2>nul

echo.
echo [DONE] Environment is ready.
echo - If you created a venv, keep this terminal open (venv is active).
echo - To start JupyterLab:  jupyter lab
popd
endlocal
