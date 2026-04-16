@echo off
REM DPI Upscaler - Quick Setup for Windows

echo.
echo ========================================
echo     DPI Upscaler - Setup Assistant
echo ========================================
echo.

REM Check if Python is available (for advanced setup)
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Python found - advanced features available
) else (
    echo [INFO] Python not found - basic features only
)

REM Check if Node.js is available
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Node.js found
) else (
    echo [INFO] Node.js not found
)

echo.
echo Files created:
echo   - index.html ..................... Main application
echo   - README.md ....................... Documentation
echo   - DEPLOYMENT.md .................. Deployment guide
echo   - ESRGAN_INTEGRATION.md .......... Advanced features
echo.

echo Next steps:
echo   1. Open index.html in your web browser
echo   2. Or deploy to GitHub Gist (see DEPLOYMENT.md)
echo   3. Share with friends!
echo.

echo For GitHub Gist deployment:
echo   1. Go to https://gist.github.com
echo   2. Paste contents of index.html
echo   3. Create public gist
echo   4. Share the raw link
echo.

echo For GitHub Pages deployment:
echo   1. Create new repo at github.com
echo   2. Upload index.html
echo   3. Enable Pages in Settings
echo   4. Access at yourusername.github.io/repo-name
echo.

echo For advanced ESRGAN support:
echo   See ESRGAN_INTEGRATION.md for detailed instructions
echo.

echo ========================================
echo     Setup Complete!
echo ========================================
echo.

pause
