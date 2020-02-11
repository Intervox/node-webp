$version = $env:webp_version

if ($version -eq $null) {
  $version = "1.1.0"
}

$url_base = "http://storage.googleapis.com/downloads.webmproject.org/releases/webp/"

$dir = $env:APPVEYOR_BUILD_FOLDER

if ($dir -eq $null) {
  $dir = [System.IO.Path]::Combine($env:SystemRoot,'system32')
}

$x64_os = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match "(x64)"

if ($x64_os -eq "True") {
  $arch = "x64"
} elseif ([version]$version -ge [version]"1.1.0") {
  Write-Error "32-bit windows binaries were dropped from libwebp starting from 1.1.0 release, consider using prior release or building webp from source"
  exit 1
} else {
  $arch = "x86"
}

$filename = "libwebp-{0}-windows-{1}.zip" -f $version,$arch
$url = $url_base + $filename

(new-object net.webclient).DownloadFile($url,$filename)

[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

$folder  = "libwebp-{0}-windows-{1}\bin" -f $version,$arch

[IO.Compression.ZipFile]::OpenRead($filename).Entries | ? {
  $_.FullName -like "$($folder -replace '\\','/')/*.exe"
} | % {
  $fname = [System.IO.Path]::GetFileName($_.FullName)
  $dest = Join-Path $dir $fname
  [IO.Compression.ZipFileExtensions]::ExtractToFile($_, $dest, $true)
}
