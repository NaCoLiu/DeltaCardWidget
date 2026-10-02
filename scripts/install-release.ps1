<#
.SYNOPSIS
  Installs the widget from a release package. / 从发布包安装小组件。

.DESCRIPTION
  1. Installs the runtime dependencies.
  2. Registers the package for the current user.
  Keep this folder where it is; Windows runs the widget from it.
  请把本文件夹放在固定位置，Windows 会直接从这里运行小组件。

  Requires Developer Mode (Settings > Privacy & security > For developers).
  需要开启开发人员模式。
#>
$ErrorActionPreference = 'Stop'
$package = Join-Path $PSScriptRoot 'package'
$dependencies = Join-Path $PSScriptRoot 'dependencies'

Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($dep in Get-ChildItem $dependencies -Filter *.appx -File -ErrorAction SilentlyContinue) {
  $archive = [System.IO.Compression.ZipFile]::OpenRead($dep.FullName)
  try {
    $manifestEntry = $archive.GetEntry('AppxManifest.xml')
    if (-not $manifestEntry) {
      throw "Missing AppxManifest.xml in dependency: $($dep.Name)"
    }
    $reader = New-Object System.IO.StreamReader($manifestEntry.Open())
    try {
      [xml]$manifest = $reader.ReadToEnd()
    }
    finally {
      $reader.Dispose()
    }
  }
  finally {
    $archive.Dispose()
  }

  $identity = $manifest.Package.Identity
  $requiredVersion = [version]$identity.Version
  $installed = Get-AppxPackage -Name $identity.Name |
    Where-Object Publisher -EQ $identity.Publisher |
    Sort-Object Version -Descending |
    Select-Object -First 1

  if ($installed -and [version]$installed.Version -ge $requiredVersion) {
    Write-Host "Already installed: $($identity.Name) $($installed.Version) (required $requiredVersion)."
    continue
  }

  Add-AppxPackage -Path $dep.FullName -ErrorAction Stop
}

Get-Process GameBar* -ErrorAction SilentlyContinue | Stop-Process -Force
Get-AppxPackage DeltaCardWidget | Remove-AppxPackage
Add-AppxPackage -Register (Join-Path $package 'AppxManifest.xml')

Write-Host 'Installed. Press Win+G and open the widget menu. / 已安装，按 Win+G 打开小组件菜单即可。'
