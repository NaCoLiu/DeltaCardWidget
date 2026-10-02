Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"

!ifndef PRODUCT_VERSION
  !define PRODUCT_VERSION "0.0.0"
!endif

!define MUI_ICON "${__FILEDIR__}\DeltaCardWidget.ico"
!define MUI_UNICON "${__FILEDIR__}\DeltaCardWidget.ico"
!define MUI_LANGDLL_REGISTRY_ROOT HKCU
!define MUI_LANGDLL_REGISTRY_KEY "Software\DeltaCardWidget"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_TEXT "Installation is complete. Open Xbox Game Bar with Win+G."
!define MUI_UNFINISHPAGE_TEXT "DeltaCardWidget has been removed."

Name "DeltaCardWidget"
OutFile "${OUTPUT_EXE}"
InstallDir "$LOCALAPPDATA\DeltaCardWidget"
InstallDirRegKey HKCU "Software\DeltaCardWidget" "InstallDir"
RequestExecutionLevel user
VIProductVersion "${PRODUCT_VERSION}.0"
VIAddVersionKey "ProductName" "DeltaCardWidget"
VIAddVersionKey "FileDescription" "DeltaCardWidget Installer"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "Install"
  SetOutPath "$INSTDIR"
  File /oname=DeltaCardWidget.ico "${__FILEDIR__}\DeltaCardWidget.ico"
  File /r "${PAYLOAD_DIR}\*"

  ExecWait '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\Install.ps1"' $0
  ${If} $0 != 0
    MessageBox MB_ICONSTOP "Installation failed. Enable Developer Mode and try again."
    Abort
  ${EndIf}

  WriteRegStr HKCU "Software\DeltaCardWidget" "InstallDir" "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeltaCardWidget" "DisplayName" "DeltaCardWidget"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeltaCardWidget" "DisplayIcon" "$INSTDIR\DeltaCardWidget.ico"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeltaCardWidget" "UninstallString" '"$INSTDIR\Uninstall.exe"'

  CreateDirectory "$SMPROGRAMS\DeltaCardWidget"
  CreateShortcut "$SMPROGRAMS\DeltaCardWidget\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\DeltaCardWidget.ico"
SectionEnd

Section "Uninstall"
  ExecWait '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\Uninstall.ps1"' $0
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeltaCardWidget"
  DeleteRegKey HKCU "Software\DeltaCardWidget"
  RMDir /r "$INSTDIR\package"
  RMDir /r "$INSTDIR\dependencies"
  Delete "$INSTDIR\Install.ps1"
  Delete "$INSTDIR\Uninstall.ps1"
  Delete "$INSTDIR\README.md"
  Delete "$INSTDIR\DeltaCardWidget.ico"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  RMDir "$SMPROGRAMS\DeltaCardWidget"
SectionEnd