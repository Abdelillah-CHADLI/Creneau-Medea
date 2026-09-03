Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot

function New-AppIcon([int]$size) {
  $bitmap = New-Object System.Drawing.Bitmap $size, $size
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.Clear([System.Drawing.Color]::FromArgb(12, 82, 48))

  $inset = [int]($size * .10)
  $field = New-Object System.Drawing.Rectangle $inset, $inset, ($size - $inset * 2), ($size - $inset * 2)
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), ([Math]::Max(2, [int]($size * .035)))
  $graphics.DrawRectangle($pen, $field)
  $middle = [int]($size / 2)
  $graphics.DrawLine($pen, $inset, $middle, ($size - $inset), $middle)
  $circleSize = [int]($size * .28)
  $graphics.DrawEllipse($pen, ($middle - $circleSize / 2), ($middle - $circleSize / 2), $circleSize, $circleSize)

  $ballSize = [int]($size * .22)
  $ballRect = [System.Drawing.Rectangle]::new(
    [int]($size * .60), [int]($size * .57), $ballSize, $ballSize
  )
  $graphics.FillEllipse([System.Drawing.Brushes]::White, $ballRect)
  $ballPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(12, 82, 48)), ([Math]::Max(1, [int]($size * .018)))
  $graphics.DrawEllipse($ballPen, $ballRect)
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
