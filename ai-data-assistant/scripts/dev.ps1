# AI Data Assistant Development Script (PowerShell)
Write-Host "🚀 Starting AI Data Assistant in development mode..." -ForegroundColor Cyan

# Change to project root
Set-Location ".."

# Check if .env exists
if (!(Test-Path ".env")) {
    Write-Host "⚠️  .env file not found. Creating from example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "📝 Please edit the .env file with your configuration and run this script again." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "✅ Development servers starting..." -ForegroundColor Green
Write-Host ""
Write-Host "📍 Access points:" -ForegroundColor Cyan
Write-Host "  • Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  • Backend:  http://localhost:3001" -ForegroundColor White
Write-Host "  • API:      http://localhost:3001/api" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop all servers" -ForegroundColor Yellow
Write-Host ""

# Start development servers using npm script
npm run dev