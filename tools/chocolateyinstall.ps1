$ErrorActionPreference = 'Stop';

$packageName = $env:ChocolateyPackageName
$version = $env:chocolateyPackageVersion
$cache = $env:Temp
$dir = Join-Path $(Join-Path $cache $packageName) $env:chocolateyPackageVersion

$toolsDir   = (Split-Path -parent $MyInvocation.MyCommand.Definition)
#$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = "https://github.com/MelonSmasher/$packageName/releases/download/v$version/$packageName-$version-windows-x86.zip"
$url64      = "https://github.com/MelonSmasher/$packageName/releases/download/v$version/$packageName-$version-windows-x86_64.zip"

$file = Join-Path $dir $packageName-$version-windows-x86.zip
$file64 = Join-Path $dir $packageName-$version-windows-x86_64.zip

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = '293dbf1871b94392451201f21eacbde33b4ba36a103871d1cd85b09b36db73d36f4b8878742c14be41ab4c5ef858d83b50ec81f9979ca179a06449e89b756e3d'
  checksumType  = 'sha512'
  checksum64    = '92097a7b0a4469f6cbc5fcdc458cecb99b82b6f1c19bde805ad644283993592f6b61ac748fd9980afddad09d6358c01b9677ecfdb5839dade1b04e3954542e17'
  checksumType64= 'sha512'
  specificFolder = $folder
}

Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $file -FileFullPath64 $file64 -Destination $installationPath

# Move everything from the subfolder to the main tools directory
$subFolder = Join-Path $installationPath (Get-ChildItem $installationPath $folder | ?{ $_.PSIsContainer })
Get-ChildItem $subFolder -Recurse | ?{$_.PSIsContainer } | Move-Item -Destination $installationPath
Get-ChildItem $subFolder | ?{$_.PSIsContainer -eq $false } | Move-Item -Destination $installationPath
Remove-Item "$subFolder"

Invoke-Expression $(Join-Path $installationPath "install-service-$($packageName).ps1")