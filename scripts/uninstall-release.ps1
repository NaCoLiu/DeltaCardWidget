$ErrorActionPreference = 'Stop'

Get-Process DeltaCard, GameBar* -ErrorAction SilentlyContinue | Stop-Process -Force
Get-AppxPackage DeltaCardWidget | Remove-AppxPackage