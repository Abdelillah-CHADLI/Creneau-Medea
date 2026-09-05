Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root 'assets/images/app_logo.png'

function New-AppIcon([int]$size) {
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Stitch app logo is missing: $sourcePath"
  }
  $bitmap = New-Object System.Drawing.Bitmap $size, $size
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.Clear([System.Drawing.Color]::FromArgb(248, 250, 252))
  $source = [System.Drawing.Image]::FromFile($sourcePath)
  $graphics.DrawImage($source, 0, 0, $size, $size)
  $source.Dispose()
  $graphics.Dispose()
  return $bitmap
}

function Save-Icon([string]$path, [int]$size) {
  $image = New-AppIcon $size
  $image.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $image.Dispose()
}

$android = @{ 'mipmap-mdpi' = 48; 'mipmap-hdpi' = 72; 'mipmap-xhdpi' = 96; 'mipmap-xxhdpi' = 144; 'mipmap-xxxhdpi' = 192 }
foreach ($entry in $android.GetEnumerator()) {
  Save-Icon (Join-Path $root "android/app/src/main/res/$($entry.Key)/ic_launcher.png") $entry.Value
}

Save-Icon (Join-Path $root 'web/favicon.png') 48
Save-Icon (Join-Path $root 'web/icons/Icon-192.png') 192
Save-Icon (Join-Path $root 'web/icons/Icon-maskable-192.png') 192
Save-Icon (Join-Path $root 'web/icons/Icon-512.png') 512
Save-Icon (Join-Path $root 'web/icons/Icon-maskable-512.png') 512

Get-ChildItem (Join-Path $root 'ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png') | ForEach-Object {
  $source = [System.Drawing.Image]::FromFile($_.FullName)
  $size = $source.Width
  $source.Dispose()
  Save-Icon $_.FullName $size
}
Get-ChildItem (Join-Path $root 'macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png') | ForEach-Object {
  $source = [System.Drawing.Image]::FromFile($_.FullName)
  $size = $source.Width
  $source.Dispose()
  Save-Icon $_.FullName $size
}

$windowsPng = New-AppIcon 256
$icon = [System.Drawing.Icon]::FromHandle($windowsPng.GetHicon())
$stream = [System.IO.File]::Open((Join-Path $root 'windows/runner/resources/app_icon.ico'), [System.IO.FileMode]::Create)
$icon.Save($stream)
$stream.Dispose()
$icon.Dispose()
$windowsPng.Dispose()
