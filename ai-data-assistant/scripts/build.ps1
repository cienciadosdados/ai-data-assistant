# AI Data Assistant Build Script (PowerShell)
Write-Host "🔨 Building AI Data Assistant for production..." -ForegroundColor Cyan

# Change to project root
Set-Location ".."

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "production") { Remove-Item "production" -Recurse -Force }
Get-ChildItem -Path . -Recurse -Directory -Name "dist" | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}
Get-ChildItem -Path . -Recurse -Directory -Name "build" | ForEach-Object {
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
}

# Build shared package first
Write-Host "🔗 Building shared package..." -ForegroundColor Yellow
Set-Location "shared"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build shared package" -ForegroundColor Red
    exit 1
}
Set-Location ".."

# Build backend
Write-Host "⚙️ Building backend..." -ForegroundColor Yellow
Set-Location "backend"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build backend" -ForegroundColor Red
    exit 1
}
Set-Location ".."

# Build frontend
Write-Host "🖥️ Building frontend..." -ForegroundColor Yellow
Set-Location "frontend"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build frontend" -ForegroundColor Red
    exit 1
}
Set-Location ".."

# Create production directory structure
Write-Host "📁 Creating production build structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "production" -Force
New-Item -ItemType Directory -Path "production\backend" -Force
New-Item -ItemType Directory -Path "production\frontend" -Force
New-Item -ItemType Directory -Path "production\shared" -Force

# Copy built files
Copy-Item "backend\dist\*" "production\backend\" -Recurse -Force
Copy-Item "backend\package.json" "production\backend\" -Force

Copy-Item "frontend\dist\*" "production\frontend\" -Recurse -Force

Copy-Item "shared\dist\*" "production\shared\" -Recurse -Force
Copy-Item "shared\package.json" "production\shared\" -Force

# Copy necessary files
Copy-Item ".env.example" "production\" -Force
Copy-Item "README.md" "production\" -Force
Copy-Item "docs" "production\" -Recurse -Force

Write-Host ""
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Production files are in the 'production' directory" -ForegroundColor Cyan
Write-Host "🚀 Deploy the contents to your production server" -ForegroundColor Cyan

pause