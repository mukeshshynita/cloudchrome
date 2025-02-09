# Use Node.js 18 as base image
FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    xvfb \
    dbus \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r steel && useradd -r -g steel -G audio,video steel \
    && mkdir -p /home/steel/Downloads \
    && chown -R steel:steel /home/steel

# Set working directory and change ownership
WORKDIR /app
COPY --chown=steel:steel . .

# Install dependencies and build
RUN npm install
RUN npm run build

# Clean up unnecessary files
RUN rm -rf /app/.git \
    && rm -rf /app/node_modules/.cache \
    && chown -R steel:steel /app

# Set up environment
ENV CHROME_BIN=/usr/bin/google-chrome-stable \
    CHROME_PATH=/usr/bin/google-chrome-stable \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable \
    NODE_ENV=production \
    DISPLAY=:99

# Create cache directory with correct permissions
RUN mkdir -p /app/.cache && chown -R steel:steel /app/.cache

# Switch to non-root user
USER steel

# Expose port
EXPOSE 3000

# Start script
COPY --chown=steel:steel docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Start the application
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npm", "start"] 