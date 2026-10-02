<#
.SYNOPSIS
  Installs the widget from a release package. / 从发布包安装小组件。

.DESCRIPTION
  1. Installs the runtime dependencies.
  2. Downloads the card artwork into the package (it is not shipped in the release).
  3. Registers the package for the current user.
  Keep this folder where it is; Windows runs the widget from it.
  请把本文件夹放在固定位置，Windows 会直接从这里运行小组件。

  Requires Developer Mode (Settings > Privacy & security > For developers).
  需要开启开发人员模式。
#>
$ErrorActionPreference = 'Stop'
$package = Join-Path $PSScriptRoot 'package'

foreach ($dep in Get-ChildItem (Join-Path $PSScriptRoot 'dependencies') -Filter *.appx -ErrorAction SilentlyContinue) {
    try { Add-AppxPackage $dep.FullName -ErrorAction Stop }
    catch { Write-Host "Skipped $($dep.Name): $($_.Exception.Message)" }   # newer version already installed
}

& (Join-Path $PSScriptRoot 'scripts\fetch-assets.ps1') -Root $package

Get-Process GameBar* -ErrorAction SilentlyContinue | Stop-Process -Force
Get-AppxPackage DeltaCardWidget | Remove-AppxPackage
Add-AppxPackage -Register (Join-Path $package 'AppxManifest.xml')

Write-Host 'Installed. Press Win+G and open the widget menu. / 已安装，按 Win+G 打开小组件菜单即可。'
