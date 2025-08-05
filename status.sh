#!/bin/bash

# Evolution API Status Check Script
# Quick verification that everything is working correctly

DOMAIN="whatsapp.soluttolabs.com"
API_KEY="B6D711FCDE4D4FD5936544120E713976"

echo "🔍 Evolution API Status Check for $DOMAIN"
echo "================================================"
echo ""

# Check Docker containers
echo "📦 Docker Container Status:"
docker-compose ps
echo ""

# Check SSL certificate
echo "🔒 SSL Certificate Status:"
if sudo certbot certificates | grep -q "$DOMAIN"; then
    echo "✅ SSL certificate is active"
    sudo certbot certificates | grep -A 3 "$DOMAIN"
else
    echo "❌ SSL certificate not found"
fi
echo ""

# Check Apache configuration
echo "🌐 Apache Configuration:"
if sudo apache2ctl configtest &>/dev/null; then
    echo "✅ Apache configuration is valid"
else
    echo "❌ Apache configuration has errors"
    sudo apache2ctl configtest
fi
echo ""

# Test API endpoints
echo "🚀 API Endpoint Tests:"

# Test main API
echo -n "  Main API (HTTPS): "
if curl -sf "https://$DOMAIN/" > /dev/null; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

# Test manager interface
echo -n "  Manager Interface: "
if curl -sf "https://$DOMAIN/manager" > /dev/null; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

# Test API with authentication
echo -n "  API with Auth: "
if curl -sf -H "apikey: $API_KEY" "https://$DOMAIN/instance/fetchInstances" > /dev/null; then
    echo "✅ Working"
else
    echo "❌ Failed"
fi

echo ""
echo "📋 Quick Access Information:"
echo "  🌐 Main API: https://$DOMAIN"
echo "  📊 Manager: https://$DOMAIN/manager"
echo "  🔑 API Key: $API_KEY"
echo "  📖 Documentation: https://doc.evolution-api.com"
echo ""

# Check logs for any errors
echo "📝 Recent Log Summary:"
echo "  Evolution API logs (last 5 lines):"
docker logs evolution_api --tail 5 2>/dev/null | sed 's/^/    /'
echo ""

echo "✅ Status check completed!"
echo "   For detailed troubleshooting, see INSTALLATION.md"
