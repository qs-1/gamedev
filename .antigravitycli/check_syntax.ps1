$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile('C:\Users\Home\Desktop\gamedev\deploy.ps1', [ref]$null, [ref]$errors)
if ($errors.Count -eq 0) {
    Write-Host 'No syntax errors!' -ForegroundColor Green
} else {
    foreach ($e in $errors) { Write-Host $e.Message -ForegroundColor Red }
}
