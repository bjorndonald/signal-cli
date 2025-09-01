# Railway Deployment Guide for signal-cli

This guide explains how to deploy signal-cli on Railway with port 8085 exposed for JSON-RPC HTTP interface.

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **Railway CLI**: Install with `npm install -g @railway/cli`
3. **Git Repository**: Your signal-cli project should be in a Git repository

## Files Created

- `Containerfile.railway` - Railway-optimized Docker container
- `railway.json` - Railway service configuration
- `.railwayignore` - Files to exclude from deployment
- `RAILWAY_DEPLOYMENT.md` - This guide

## Deployment Steps

### 1. Build the Railway Image Locally (Optional)

```bash
# Build the Railway-specific image
docker build --no-cache --platform linux/amd64 -f Containerfile.railway -t signal-cli-railway .

# Test locally
docker run --platform linux/amd64 -p 8085:8085 -v ~/signal-cli-config:/var/lib/signal-cli signal-cli-railway
```

### 2. Deploy to Railway

```bash
# Login to Railway
railway login

# Initialize Railway project (if not already done)
railway init

# Deploy the service
railway up

# Check deployment status
railway status
```

### 3. Configure Environment Variables

In Railway dashboard, set these environment variables:

```bash
# Optional: Set a custom port (defaults to 8085)
PORT=8085

# Optional: Set service environment
SERVICE_ENVIRONMENT=live
```

### 4. Set Up Signal Account

**Important**: You need to configure a Signal account before the daemon can start.

#### Option A: Use Railway CLI to run commands

```bash
# Connect to your Railway service
railway connect

# Register a new account (replace +1234567890 with your number)
signal-cli -a +1234567890 register

# Verify with the code received via SMS
signal-cli -a +1234567890 verify 123456

# Start the daemon manually (for testing)
signal-cli -a +1234567890 daemon --http 0.0.0.0:8085
```

#### Option B: Use Railway's shell feature

1. Go to Railway dashboard
2. Navigate to your service
3. Click on "Shell" tab
4. Run the registration commands above

### 5. Access the JSON-RPC Interface

Once deployed and configured, your signal-cli JSON-RPC interface will be available at:

```
https://your-railway-app.railway.app:8085
```

## API Usage Examples

### Send a Message

```bash
curl -X POST https://your-railway-app.railway.app:8085 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "send",
    "params": {
      "account": "+1234567890",
      "recipient": "+0987654321",
      "message": "Hello from Railway!"
    }
  }'
```

### Receive Messages

```bash
curl -X POST https://your-railway-app.railway.app:8085 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "receive",
    "params": {
      "account": "+1234567890"
    }
  }'
```

## Configuration Options

### Port Configuration

The service runs on port 8085 by default. You can change this by:

1. Modifying `EXPOSE 8085` in `Containerfile.railway`
2. Setting the `PORT` environment variable in Railway
3. Updating the startup script to use the environment variable

### Persistent Storage

Railway provides persistent storage for your `/var/lib/signal-cli` directory. This means:
- Your Signal account configuration persists between deployments
- Message history and contacts are preserved
- You don't need to re-register after redeployments

## Troubleshooting

### Common Issues

1. **"No Signal account configured"**
   - Follow the account setup steps above
   - Ensure you've registered and verified your phone number

2. **Port binding issues**
   - Check that port 8085 is exposed in the Containerfile
   - Verify Railway has assigned the correct port

3. **Native library errors**
   - The Containerfile.railway includes the necessary native libraries
   - Ensure you're building for linux/amd64 platform

### Logs

View logs in Railway dashboard:
1. Go to your service
2. Click on "Logs" tab
3. Look for any error messages or startup issues

## Security Considerations

1. **Authentication**: The JSON-RPC interface is not authenticated by default
2. **Network Access**: The service binds to 0.0.0.0:8085 (accepts all connections)
3. **Data Privacy**: Signal data is stored in Railway's persistent storage

## Scaling

Railway automatically scales your service based on demand. The signal-cli daemon is designed to handle multiple concurrent connections.

## Monitoring

Monitor your service health through:
- Railway dashboard metrics
- Application logs
- Signal account status

## Support

For Railway-specific issues: [Railway Support](https://railway.app/support)
For signal-cli issues: [GitHub Issues](https://github.com/AsamK/signal-cli/issues)
