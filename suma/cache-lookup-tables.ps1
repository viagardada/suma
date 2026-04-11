#!/usr/bin/env pwsh

# Cache lookup tables to the local Runner cache.

$version_file = 'C:/cache/LookupTables/sUMA_4.2.0'
if (-not (Test-Path $version_file) -or
          $env:CI_INVALIDATE_CACHES -eq 'true') {
     Remove-Item -Recurse 'C:/cache/LookupTables' -ea SilentlyContinue
     Write-Output "Caching Lookup Tables..."
     curl.exe -Lfs -u "${env:GENERIC_USERNAME}:${env:GENERIC_PASSWORD}" "${env:GENERIC_REPOSITORY_URL}/suma/data/sUMA_4.2.0.tar.gz" -o LookupTables.tar.gz
     if ($LASTEXITCODE -ne 0)
     {
          throw "Download failed: $LASTEXITCODE"
     }
     tar.exe xvf LookupTables.tar.gz -C 'C:/cache'
     if ($LASTEXITCODE -ne 0)
     {
          throw "Extraction failed: $LASTEXITCODE"
     }
     "" | Out-File $version_file
}
else {
     Write-Output "Found Lookup Table cache."
}
