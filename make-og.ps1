Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# --- base warm background ---
$bg = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#fff7f0'))
$g.FillRectangle($bg, 0, 0, $W, $H)

# --- soft radial glows (match the card) ---
function Add-Glow($hex, $alpha, $cx, $cy, $r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(($cx - $r), ($cy - $r), ($r * 2), ($r * 2))
  $pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
  $c = [System.Drawing.ColorTranslator]::FromHtml($hex)
  $pgb.CenterColor = [System.Drawing.Color]::FromArgb($alpha, $c.R, $c.G, $c.B)
  $pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $c.R, $c.G, $c.B))
  $g.FillPath($pgb, $path)
  $pgb.Dispose(); $path.Dispose()
}
Add-Glow '#ff8a5c' 170 180 110 640
Add-Glow '#ff5c8a' 150 1060 140 660
Add-Glow '#7c5cff' 140 620 760 720

# --- rounded-rect helper ---
function Get-RoundRect($x, $y, $w, $h, $r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddArc($x, $y, $r, $r, 180, 90)
  $p.AddArc(($x + $w - $r), $y, $r, $r, 270, 90)
  $p.AddArc(($x + $w - $r), ($y + $h - $r), $r, $r, 0, 90)
  $p.AddArc($x, ($y + $h - $r), $r, $r, 90, 90)
  $p.CloseFigure()
  return $p
}

# --- terminal chip ---
$chipText = 'dad@home:~$ ./happy-fathers-day --dad'
$chipFont = New-Object System.Drawing.Font('Consolas', 22, [System.Drawing.FontStyle]::Regular)
$size = $g.MeasureString($chipText, $chipFont)
$padX = 30; $padY = 16
$chipW = [int]($size.Width + $padX * 2); $chipH = [int]($size.Height + $padY * 2)
$chipX = [int](($W - $chipW) / 2); $chipY = 96
$chipPath = Get-RoundRect $chipX $chipY $chipW $chipH 18
$dark = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#0b0f14'))
$g.FillPath($dark, $chipPath)
$green = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#39d98a'))
$sfMid = New-Object System.Drawing.StringFormat
$sfMid.Alignment = [System.Drawing.StringAlignment]::Center
$sfMid.LineAlignment = [System.Drawing.StringAlignment]::Center
$chipRect = New-Object System.Drawing.RectangleF($chipX, $chipY, $chipW, $chipH)
$g.DrawString($chipText, $chipFont, $green, $chipRect, $sfMid)

# --- title ---
$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$titleFont = New-Object System.Drawing.Font('Georgia', 72, [System.Drawing.FontStyle]::Bold)
$ink = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#2a1a14'))
$g.DrawString("Happy Father's Day,", $titleFont, $ink, ($W / 2), 230, $sfCenter)
$g.DrawString("Dad", $titleFont, $ink, ($W / 2), 330, $sfCenter)

# --- subtitle ---
$subFont = New-Object System.Drawing.Font('Georgia', 30, [System.Drawing.FontStyle]::Italic)
$subBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#b5642f'))
$g.DrawString("made just for you   .   tap to open", $subFont, $subBrush, ($W / 2), 460, $sfCenter)

# --- save ---
$out = 'C:\Users\Yuvan\fathers-day-gift\og.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "Saved $out"
