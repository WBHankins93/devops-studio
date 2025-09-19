#!/bin/bash
# modules/web-app/user-data.sh
# User data script to set up a simple web application with monitoring

set -e

# Template variables (filled by Terraform)
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"
REGION="${region}"

# System updates and basic packages
yum update -y
yum install -y httpd htop aws-cli amazon-cloudwatch-agent

# Install Node.js (for modern web apps)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/${PROJECT_NAME}-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/httpd/access.log",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/${PROJECT_NAME}-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/httpd/error.log",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/${PROJECT_NAME}-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/system/messages",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "DevOpsStudio/EC2",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start and enable CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a simple Node.js application
mkdir -p /var/www/app
cd /var/www/app

# Package.json
cat > package.json << 'EOF'
{
  "name": "devops-studio-app",
  "version": "1.0.0",
  "description": "Simple web application for DevOps Studio",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "aws-sdk": "^2.1400.0"
  }
}
EOF

# Install dependencies
npm install

# Create the main application
cat > server.js << EOF
const express = require('express');
const AWS = require('aws-sdk');
const fs = require('fs');
const os = require('os');

const app = express();
const port = 3000;

// Configure AWS SDK
AWS.config.update({ region: '${REGION}' });
const ssm = new AWS.SSM();

// Middleware
app.use(express.static('public'));
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        instance: '${INSTANCE_ID}',
        uptime: process.uptime()
    });
});

// Main application endpoint
app.get('/', async (req, res) => {
    try {
        // Get configuration from SSM (if any)
        let config = {};
        try {
            const params = {
                Path: '/${PROJECT_NAME}/${ENVIRONMENT}/',
                Recursive: true
            };
            const result = await ssm.getParametersByPath(params).promise();
            result.Parameters.forEach(param => {
                const key = param.Name.split('/').pop();
                config[key] = param.Value;
            });
        } catch (err) {
            console.log('No SSM parameters found or error:', err.message);
        }

        const html = \`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>DevOps Studio - \${config.app_name || 'Web Application'}</title>
            <style>
                body {
                    font-family: 'Arial', sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    margin: 0;
                    padding: 20px;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                .container {
                    background: rgba(255, 255, 255, 0.1);
                    backdrop-filter: blur(10px);
                    border-radius: 15px;
                    padding: 40px;
                    max-width: 800px;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
                }
                h1 {
                    text-align: center;
                    margin-bottom: 30px;
                    font-size: 2.5em;
                }
                .info-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                    gap: 20px;
                    margin-top: 30px;
                }
                .info-card {
                    background: rgba(255, 255, 255, 0.1);
                    padding: 20px;
                    border-radius: 10px;
                    border: 1px solid rgba(255, 255, 255, 0.2);
                }
                .info-card h3 {
                    margin-top: 0;
                    color: #ffd700;
                }
                .status {
                    display: inline-block;
                    padding: 5px 15px;
                    background: #4CAF50;
                    border-radius: 20px;
                    font-weight: bold;
                }
                .footer {
                    text-align: center;
                    margin-top: 30px;
                    opacity: 0.8;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 DevOps Studio</h1>
                <p style="text-align: center; font-size: 1.2em;">
                    Production-Ready Infrastructure Demo
                </p>
                <p style="text-align: center;">
                    <span class="status">OPERATIONAL</span>
                </p>
                
                <div class="info-grid">
                    <div class="info-card">
                        <h3>🏗️ Infrastructure</h3>
                        <p><strong>Project:</strong> ${PROJECT_NAME}</p>
                        <p><strong>Environment:</strong> ${ENVIRONMENT}</p>
                        <p><strong>Region:</strong> ${REGION}</p>
                        <p><strong>AZ:</strong> ${AZ}</p>
                    </div>
                    
                    <div class="info-card">
                        <h3>💻 Instance Details</h3>
                        <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
                        <p><strong>Private IP:</strong> ${PRIVATE_IP}</p>
                        <p><strong>Hostname:</strong> \${os.hostname()}</p>
                        <p><strong>Uptime:</strong> \${Math.floor(process.uptime())}s</p>
                    </div>
                    
                    <div class="info-card">
                        <h3>⚙️ Features Demonstrated</h3>
                        <ul style="margin: 0; padding-left: 20px;">
                            <li>Auto Scaling Groups</li>
                            <li>Application Load Balancer</li>
                            <li>CloudWatch Monitoring</li>
                            <li>SSM Parameter Store</li>
                            <li>VPC with 3-Tier Architecture</li>
                        </ul>
                    </div>
                    
                    <div class="info-card">
                        <h3>📊 Monitoring</h3>
                        <p><strong>Health Check:</strong> <a href="/health" style="color: #ffd700;">/health</a></p>
                        <p><strong>Metrics:</strong> <a href="/metrics" style="color: #ffd700;">/metrics</a></p>
                        <p><strong>Load Test:</strong> <a href="/load" style="color: #ffd700;">/load</a></p>
                    </div>
                </div>
                
                <div class="footer">
                    <p>Built with ❤️ using Terraform, AWS, and DevOps best practices</p>
                    <p>Request ID: \${req.ip}-\${Date.now()}</p>
                </div>
            </div>
        </body>
        </html>
        \`;
        
        res.send(html);
        
        // Log the request
        console.log(\`[\${new Date().toISOString()}] GET / - \${req.ip} - Instance: ${INSTANCE_ID}\`);
        
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Internal server error', instance: '${INSTANCE_ID}' });
    }
});

// Metrics endpoint for monitoring
app.get('/metrics', (req, res) => {
    const metrics = {
        timestamp: new Date().toISOString(),
        instance_id: '${INSTANCE_ID}',
        availability_zone: '${AZ}',
        uptime_seconds: process.uptime(),
        memory_usage: process.memoryUsage(),
        cpu_usage: os.loadavg(),
        hostname: os.hostname(),
        platform: os.platform(),
        node_version: process.version
    };
    
    res.json(metrics);
});

// Load testing endpoint
app.get('/load', (req, res) => {
    const iterations = req.query.iterations || 1000000;
    const start = Date.now();
    
    // Simulate some CPU load
    let result = 0;
    for (let i = 0; i < iterations; i++) {
        result += Math.sqrt(i);
    }
    
    const duration = Date.now() - start;
    
    res.json({
        message: 'Load test completed',
        iterations: iterations,
        duration_ms: duration,
        result: result,
        instance: '${INSTANCE_ID}'
    });
});

// Start the server
app.listen(port, () => {
    console.log(\`Server running on port \${port}\`);
    console.log(\`Instance: ${INSTANCE_ID}\`);
    console.log(\`Environment: ${ENVIRONMENT}\`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
});
EOF

# Create systemd service
cat > /etc/systemd/system/devops-app.service << 'EOF'
[Unit]
Description=DevOps Studio Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Configure Apache as reverse proxy
cat > /etc/httpd/conf.d/devops-app.conf << 'EOF'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyRequests Off
    ProxyPass /health http://localhost:3000/health
    ProxyPassReverse /health http://localhost:3000/health
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
    
    # Health check endpoint for ALB
    <Location "/health">
        ProxyPass http://localhost:3000/health
        ProxyPassReverse http://localhost:3000/health
    </Location>
</VirtualHost>
EOF

# Set permissions
chown -R ec2-user:ec2-user /var/www/app
chmod +x /var/www/app/server.js

# Enable and start services
systemctl enable httpd
systemctl enable devops-app
systemctl start httpd
systemctl start devops-app

# Wait for application to start
sleep 10

# Test the application
curl -f http://localhost:3000/health || {
    echo "Application failed to start, checking logs..."
    journalctl -u devops-app --no-pager
    exit 1
}

echo "Web application setup completed successfully!"
echo "Instance ID: $INSTANCE_ID"
echo "Health check: http://localhost/health"

# Send success signal to CloudFormation (if using CF)
# This is a best practice for signaling successful instance initialization
yum install -y python3-pip
pip3 install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz

# Create a simple success indicator file
echo "$(date): Web application successfully initialized on instance $INSTANCE_ID" > /var/log/init-success.log

# Optional: Send custom metric to CloudWatch
aws cloudwatch put-metric-data \
    --region "$REGION" \
    --namespace "DevOpsStudio/Initialization" \
    --metric-data MetricName=InstanceInitialized,Value=1,Unit=Count,Dimensions=Environment="$ENVIRONMENT",Project="$PROJECT_NAME"