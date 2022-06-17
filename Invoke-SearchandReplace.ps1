<#
Pete Lenhart
Search and Replace words in files.
#>

#Enter file name here
$fileName = ""

#The term you want to match.
$match = ""

#The replacement term
$replacement = ""

#Begin
$content = Get-Content $fileName
$content

$content = $content -creplace $match, $replacement
$content

$content | Set-Content $fileName

Write-Host "Done"
