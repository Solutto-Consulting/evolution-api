#!/bin/bash

# Evolution API Setup Script for whatsapp.soluttolabs.com
# This script sets up Apache virtual host and SSL certificate with proper staging

set -e

DOMAIN="whatsapp.soluttolabs.com"
VHOST_FILE="whatsapp.soluttolabs.com.conf"
APACHE_SITES_DIR="/etc/apache2/sites-available"
PROJECT_DIR="/home/solutto/apps/whatsapp.soluttolabs.com"
EMAIL="admin@soluttolabs.com"

echo "🚀 Setting up Evolution API for $DOMAIN"
echo "📋 This script will:"
echo "   - Configure Apache with SSL"
echo "   - Generate Let's Encrypt certificate"
echo "   - Start Evolution API with proper configuration"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)" 
   exit 1
fi

# Check if domain points to this server
echo "🔍 Checking DNS resolution for $DOMAIN..."
if ! nslookup $DOMAIN > /dev/null 2>&1; then
    echo "⚠️  Warning: Could not resolve $DOMAIN. Make sure DNS is configured properly."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Enable required Apache modules
echo "📦 Enabling required Apache modules..."
a2enmod rewrite ssl proxy proxy_http proxy_wstunnel headers

# Install certbot if not installed
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing certbot..."
    apt update
    apt install -y certbot python3-certbot-apache
fi

# Disable any existing sites with same name
echo "🔧 Preparing Apache configuration..."
if [ -f "$APACHE_SITES_DIR/$VHOST_FILE" ]; then
    a2dissite "$VHOST_FILE" || true
fi

# Create temporary HTTP-only virtual host for certificate generation
echo "📋 Creating temporary HTTP configuration..."
cat > "$APACHE_SITES_DIR/$VHOST_FILE" << EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot /var/www/html
    
    # Proxy configuration for Evolution API
    ProxyPreserveHost On
    ProxyRequests Off
    
    # WebSocket support
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) ws://localhost:8080/\$1 [P,L]
    
    # Standard HTTP proxy
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    # Set headers for proper proxying
    ProxyPreserveHost On
    ProxyAddHeaders On
    RequestHeader set X-Forwarded-Proto "http"
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOF

# Enable the site and test configuration
echo "🔗 Enabling Apache site..."
a2ensite "$VHOST_FILE"
apache2ctl configtest
systemctl reload apache2

# Start Evolution API
echo "🐳 Starting Evolution API..."
cd "$PROJECT_DIR"
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for Evolution API to start..."
sleep 30

# Check if Evolution API is responding
echo "🔍 Testing Evolution API..."
if curl -f -s http://localhost:8080/ > /dev/null; then
    echo "✅ Evolution API is running"
else
    echo "❌ Evolution API is not responding. Check logs with: docker-compose logs"
    exit 1
fi

# Generate SSL certificate
echo "🔐 Generating SSL certificate..."
certbot --apache -d "$DOMAIN" --non-interactive --agree-tos --email "$EMAIL"

# Test HTTPS access
echo "🔍 Testing HTTPS access..."
sleep 10
if curl -f -s "https://$DOMAIN/" > /dev/null; then
    echo "✅ HTTPS is working correctly"
else
    echo "⚠️  HTTPS might still be starting. Test manually: https://$DOMAIN"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Access your Evolution API:"
echo "   🌐 Main API: https://$DOMAIN"
echo "   📊 Manager: https://$DOMAIN/manager"
echo "   🔑 Global API Key: B6D711FCDE4D4FD5936544120E713976"
echo ""
echo "📚 Useful commands:"
echo "   📊 Check status: docker-compose ps"
echo "   📝 View logs: docker-compose logs -f"
echo "   🔄 Restart: docker-compose restart"
echo "   🔐 SSL status: sudo certbot certificates"
echo ""
echo "🔒 SSL certificate will auto-renew via cron"
echo "📖 Documentation: https://doc.evolution-api.com/"
