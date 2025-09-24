# AI Data Assistant Setup Script (PowerShell)
Write-Host "🤖 Setting up AI Data Assistant..." -ForegroundColor Cyan

# Check if Node.js is installed
try {
    $nodeVersion = node -v
    Write-Host "✅ Node.js $nodeVersion detected" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 18+ and try again." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check Node.js version
$nodeVersionNum = $nodeVersion.Replace('v', '').Split('.')[0]
if ([int]$nodeVersionNum -lt 18) {
    Write-Host "❌ Node.js version 18 or higher is required. Current version: $nodeVersion" -ForegroundColor Red
    exit 1
}

# Check if npm is installed
try {
    $npmVersion = npm -v
    Write-Host "✅ npm $npmVersion detected" -ForegroundColor Green
} catch {
    Write-Host "❌ npm is not installed. Please install npm and try again." -ForegroundColor Red
    exit 1
}

# Change to project root
Set-Location ".."

# Install root dependencies
Write-Host "📦 Installing root dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install root dependencies" -ForegroundColor Red
    exit 1
}

# Setup shared package
Write-Host "🔗 Setting up shared package..." -ForegroundColor Yellow
Set-Location "shared"
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install shared dependencies" -ForegroundColor Red
    exit 1
}

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build shared package" -ForegroundColor Red
    exit 1
}

Set-Location ".."

# Setup backend
Write-Host "⚙️ Setting up backend..." -ForegroundColor Yellow
Set-Location "backend"
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install backend dependencies" -ForegroundColor Red
    exit 1
}

# Create logs directory
if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs"
    Write-Host "📁 Created logs directory" -ForegroundColor Green
}

Set-Location ".."

# Setup frontend
Write-Host "🖥️ Setting up frontend..." -ForegroundColor Yellow
Set-Location "frontend"
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install frontend dependencies" -ForegroundColor Red
    exit 1
}

Set-Location ".."

# Create .env file if it doesn't exist
if (!(Test-Path ".env")) {
    Write-Host "📝 Creating .env file from example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "⚠️  Please edit the .env file with your actual configuration values." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Edit the .env file with your configuration" -ForegroundColor White
Write-Host "2. Set up your Supabase database using docs/supabase-setup.sql" -ForegroundColor White
Write-Host "3. Run 'npm run dev' to start the development servers" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Happy coding!" -ForegroundColor Green

# Keep window open
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")