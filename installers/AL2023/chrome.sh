#!/usr/bin/env bash
set -e

# Install Google Chrome, ChromeDriver, and Selenium on AL2023.
# Chrome requires --no-sandbox on CDDs (no kernel namespaces).
# ChromeDriver version must exactly match the installed Chrome version.
# Reference: https://w.amazon.com/bin/view/Users/dkag/CDD/AL2023/Chrome/

# --- Chrome ---

if command -v google-chrome-stable &>/dev/null; then
  echo "Chrome already installed: $(google-chrome-stable --version)"
else
  echo "Installing Google Chrome..."
  curl -sL "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" -o /tmp/chrome.rpm
  sudo dnf install -y liberation-fonts
  sudo dnf install -y /tmp/chrome.rpm
  rm -f /tmp/chrome.rpm
  echo "Installed: $(google-chrome-stable --version)"
fi

# --- ChromeDriver ---

CHROME_VER=$(google-chrome-stable --version | grep -oP '\d+\.\d+\.\d+\.\d+')
CHROMEDRIVER_DIR=/usr/local/bin

if [ -x "$CHROMEDRIVER_DIR/chromedriver" ] && "$CHROMEDRIVER_DIR/chromedriver" --version 2>/dev/null | grep -q "$CHROME_VER"; then
  echo "ChromeDriver already matches Chrome $CHROME_VER"
else
  echo "Installing ChromeDriver for Chrome $CHROME_VER..."
  curl -sL "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VER}/linux64/chromedriver-linux64.zip" -o /tmp/chromedriver.zip
  cd /tmp && unzip -o chromedriver.zip
  sudo install -m 755 /tmp/chromedriver-linux64/chromedriver "$CHROMEDRIVER_DIR/chromedriver"
  rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64
  echo "Installed: $(chromedriver --version)"
fi

# --- Selenium (pip) ---

if pip3 show selenium &>/dev/null; then
  echo "Selenium already installed: $(pip3 show selenium | grep Version)"
else
  echo "Installing Selenium..."
  pip3 install selenium
  echo "Installed: $(pip3 show selenium | grep Version)"
fi

echo ""
echo "Done. Note: use --no-sandbox when launching Chrome on AL2023 CDDs."
