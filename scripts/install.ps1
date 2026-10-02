<#
.SYNOPSIS
  Builds the widget (Release x64) and registers it for the current user.
  构建小组件（Release x64）并为当前用户注册安装。

.NOTES
  Requires Visual Studio 2022 with the UWP workload, the Windows 10/11 SDK, and Developer Mode.
  需要 Visual Studio 2022（含 UWP 工作负载）、Windows SDK，并开启开发人员模式。
#>
param(
    [string]$MSBuild = 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe'
)

$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '..\DeltaCard' | Resolve-Path
Push-Location $project
try {
    if (-not (Test-Path 'Assets\Cards')) {
        throw 'Card images are missing. Run scripts\fetch-assets.ps1 first. / 缺少牌面图片，请先运行 scripts\fetch-assets.ps1。'
    }

    Get-Process DeltaCard, GameBar* -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-AppxPackage DeltaCardWidget | Remove-AppxPackage
    Remove-Item bin, obj, AppPackages, layout -Recurse -Force -ErrorAction SilentlyContinue

    & $MSBuild DeltaCard.csproj -restore -p:Configuration=Release -p:Platform=x64 -p:AppxBundle=Never -v:q -clp:ErrorsOnly
    if ($LASTEXITCODE -ne 0) { throw 'Build failed. / 构建失败。' }

    # An unsigned package can only be registered from loose files, so unpack the .msix.
    $makeappx = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\makeappx.exe" | Sort-Object FullName | Select-Object -Last 1
    $msix = Get-ChildItem AppPackages -Recurse -Filter *.msix | Select-Object -First 1
    & $makeappx.FullName unpack /p $msix.FullName /d layout /nv /o | Out-Null
    Add-AppxPackage -Register layout\AppxManifest.xml

    Write-Host 'Installed. Press Win+G and open the widget menu. / 已安装，按 Win+G 打开小组件菜单即可。'
}
finally {
    Pop-Location
}
