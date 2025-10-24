# PowerShell script to run docker-compose up --build
# Usage: .\run.ps1

Write-Host "Building and starting containers..." -ForegroundColor Green
docker-compose up --build