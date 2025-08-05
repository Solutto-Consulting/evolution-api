# Evolution API Installation for whatsapp.soluttolabs.com

🚀 **Complete setup guide for Evolution API with Apache reverse proxy and SSL certificate**

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Ubuntu/Debian server with root access
- ✅ Domain `whatsapp.soluttolabs.com` pointing to your server IP
- ✅ Apache2 installed and running
- ✅ Docker and Docker Compose installed
- ✅ Ports 80, 443, and 8080 open

## 🚀 Quick Installation

### One-Command Setup

```bash
sudo ./install.sh
```

This automated script will:
1. Configure Apache modules
2. Set up virtual host configuration
3. Generate SSL certificate with Let's Encrypt
4. Start Evolution API containers
5. Configure everything for HTTPS

## 🔧 Manual Installation

If you prefer step-by-step installation:

### 1. Enable Apache Modules

```bash
sudo a2enmod rewrite ssl proxy proxy_http proxy_wstunnel headers
```

### 2. Install Certbot

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-apache
```

### 3. Start Evolution API

```bash
docker-compose up -d
```

### 4. Generate SSL Certificate

```bash
sudo certbot --apache -d whatsapp.soluttolabs.com --email admin@soluttolabs.com --agree-tos --non-interactive
```

## 📊 Access Your Installation

After successful installation:

| Service | URL | Purpose |
|---------|-----|---------|
| **Main API** | https://whatsapp.soluttolabs.com | REST API endpoints |
| **Manager Interface** | https://whatsapp.soluttolabs.com/manager | Web management panel |
| **Documentation** | https://doc.evolution-api.com | Official API docs |

## 🔑 Authentication

### Global API Key
- **Key**: `B6D711FCDE4D4FD5936544120E713976`
- **Usage**: Required for manager access and administrative functions
- **Header**: `apikey: B6D711FCDE4D4FD5936544120E713976`

### Example API Usage

```bash
# Test API access
curl -X GET https://whatsapp.soluttolabs.com/instance/fetchInstances \
  -H "apikey: B6D711FCDE4D4FD5936544120E713976"

# Create new instance
curl -X POST https://whatsapp.soluttolabs.com/instance/create \
  -H "Content-Type: application/json" \
  -H "apikey: B6D711FCDE4D4FD5936544120E713976" \
  -d '{
    "instanceName": "my-whatsapp",
    "qrcode": true
  }'
```

## 🛠 Management Commands

### Docker Commands
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update containers
docker-compose pull && docker-compose up -d
```

### SSL Certificate Management
```bash
# Check certificate status
sudo certbot certificates

# Test renewal
sudo certbot renew --dry-run

# Force renewal
sudo certbot renew --force-renewal
```

### Apache Management
```bash
# Check Apache status
sudo systemctl status apache2

# Test configuration
sudo apache2ctl configtest

# Reload configuration
sudo systemctl reload apache2

# View error logs
sudo tail -f /var/log/apache2/whatsapp.soluttolabs.com_error.log
```

## 📁 Configuration Files

### Key Files Location
```
/home/solutto/apps/whatsapp.soluttolabs.com/
├── .env                           # Evolution API configuration
├── docker-compose.yaml           # Docker services definition
├── whatsapp.soluttolabs.com.conf # Apache virtual host
└── install.sh                    # Installation script

/etc/apache2/sites-available/
└── whatsapp.soluttolabs.com.conf # Apache configuration

/etc/letsencrypt/live/whatsapp.soluttolabs.com/
├── fullchain.pem                 # SSL certificate
└── privkey.pem                   # SSL private key
```

### Environment Configuration (`.env`)

Key settings in your `.env` file:
```bash
SERVER_TYPE=http                  # Internal HTTP (SSL handled by Apache)
SERVER_PORT=8080                  # Internal port
SERVER_URL=https://whatsapp.soluttolabs.com  # External HTTPS URL

# Authentication
AUTHENTICATION_TYPE=apikey
AUTHENTICATION_API_KEY=B6D711FCDE4D4FD5936544120E713976

# Database
DATABASE_PROVIDER=postgresql
DATABASE_CONNECTION_URI='postgresql://user:pass@postgres:5432/evolution_db?schema=evolution_api'

# Redis Cache
CACHE_REDIS_ENABLED=true
CACHE_REDIS_URI=redis://redis:6379/0
```

## 🔒 Security Features

Your installation includes:

- ✅ **SSL/TLS encryption** with Let's Encrypt certificate
- ✅ **HSTS headers** for enhanced security
- ✅ **API key authentication** for access control
- ✅ **Reverse proxy** hiding internal services
- ✅ **Automatic certificate renewal** via cron
- ✅ **Security headers** (X-Frame-Options, X-Content-Type-Options)

## 🔧 Troubleshooting

### Common Issues

#### Evolution API not starting
```bash
# Check logs
docker-compose logs evolution_api

# Restart container
docker-compose restart api
```

#### SSL certificate issues
```bash
# Check certificate
sudo certbot certificates

# Test Apache config
sudo apache2ctl configtest
```

#### Connection issues
```bash
# Test internal connection
curl http://localhost:8080/

# Test external connection
curl https://whatsapp.soluttolabs.com/

# Check DNS
nslookup whatsapp.soluttolabs.com
```

### Performance Optimization

#### For high-traffic installations:

1. **Increase database connections** in `.env`:
```bash
DATABASE_CONNECTION_URI='postgresql://user:pass@postgres:5432/evolution_db?schema=evolution_api&connection_limit=50'
```

2. **Enable Redis cache**:
```bash
CACHE_REDIS_ENABLED=true
CACHE_LOCAL_ENABLED=false
```

3. **Configure log levels**:
```bash
LOG_LEVEL=ERROR,WARN,INFO
LOG_BAILEYS=error
```

## 📚 Additional Resources

- 📖 **Official Documentation**: https://doc.evolution-api.com/
- 💬 **Community Support**: https://github.com/EvolutionAPI/evolution-api/discussions
- 🐛 **Bug Reports**: https://github.com/EvolutionAPI/evolution-api/issues
- 🔄 **Updates**: https://github.com/EvolutionAPI/evolution-api/releases

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review container logs: `docker-compose logs`
3. Verify Apache configuration: `sudo apache2ctl configtest`
4. Test SSL certificate: `sudo certbot certificates`
5. Check DNS resolution: `nslookup whatsapp.soluttolabs.com`

---

**✅ Installation completed successfully!**

Your Evolution API is now running securely at: **https://whatsapp.soluttolabs.com**
