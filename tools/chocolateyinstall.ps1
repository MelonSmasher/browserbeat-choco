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
  checksum      = '414746baee90e443a9a74562eb044c1b37e1a0b20b447f0ab3f8f9669e8742a234cb08386e2a17042f3321b74a413aa7bb3afd10380ba1412eeb188fa4a73062'
  checksumType  = 'sha512'
  checksum64    = '7865a5ce29b22c1d4d0242f9cc145d9fdff1ca034faa1cbc8572efe7681a01f1b7ab6462211cfaa8d7702a2101bb806a361d3bddc4e3c50bb2611278b988ebd8'
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