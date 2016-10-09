$file = Get-Content .\StreamTemplate.ini
$destination = ".\Streams.inc"
$count = 20
Clear-Content $destination


for ($i=0; $i -le $count; $i++) {
  foreach ($line in $file) {
    $line -replace "!i!", $i | Add-Content -Path $destination
  }
}