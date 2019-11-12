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
  checksum      = '74078321006380e00a52d87c16b7e8e2523abad0530e6575d229af63025989dcf8a1be603bc46dc9ccdefb88b8706754eb5ed8811312c0d4ecf06ca709c874e0'
  checksumType  = 'sha512'
  checksum64    = '2e542d1e6527e47e6a788de2933229ebb888f55fac800f21ce7b5a7c97d5416dccabd0d276964fe03cddd0f385d62b00659dc94b5e579abdf6ba40dd4ae2ca40'
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