$ErrorActionPreference = "Stop"
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
    $docxPath = (Resolve-Path "$pwd\rapport_TP1.docx").Path
    $pdfPath = "$pwd\rapport_TP1.pdf"
    if (Test-Path $pdfPath) { Remove-Item $pdfPath }
    $doc = $word.Documents.Open($docxPath)
    $doc.SaveAs([ref]$pdfPath, [ref]17)
    $doc.Close([ref]0)
    Write-Host "SUCCESS"
} catch {
    Write-Host "ERROR: $_"
} finally {
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
}
