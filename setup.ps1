# Load environment variables from .env file
$envFilePath = ".\.env"
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+?)\s*=\s*(.+?)\s*$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
} else {
    Write-Host "Environment file not found: $envFilePath" -ForegroundColor Red
    exit 1
}


# Create required directories
Write-Host "Creating development directories..." -ForegroundColor Yellow

$directories = @(
    $env:DEV_WORKSPACE_DIR,
    $env:DB_DIR,
    $env:DEV_WORKSPACE_LOG_DIR,
    $env:DB_LOG_DIR
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir
        Write-Host "Created directory: $dir" -ForegroundColor Green
    } else {
        Write-Host "Directory already exists: $dir" -ForegroundColor Cyan
    }
}

Write-Host "Development environment setup completed!" -ForegroundColor Green