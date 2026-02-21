import express from 'express';

const app = express();
const port = process.env.PORT || 3000;

// Sample data source - simulates real metrics
function getSampleData() {
  const now = Date.now();
  const hourlyData = [];
  for (let i = 23; i >= 0; i--) {
    hourlyData.push({
      time: new Date(now - i * 3600000).toISOString(),
      requests: Math.floor(Math.random() * 5000) + 8000,
      errors: Math.floor(Math.random() * 50) + 10,
      responseTime: Math.floor(Math.random() * 100) + 150
    });
  }
  
  return {
    overview: {
      activeServices: 12,
      totalRequests: hourlyData.reduce((sum, h) => sum + h.requests, 0),
      errorRate: (hourlyData.reduce((sum, h) => sum + h.errors, 0) / 
                  hourlyData.reduce((sum, h) => sum + h.requests, 0) * 100).toFixed(2),
      avgResponseTime: Math.floor(hourlyData.reduce((sum, h) => sum + h.responseTime, 0) / hourlyData.length),
      uptime: 99.95,
      openIncidents: 3
    },
    hourlyData,
    services: [
      { name: 'API Gateway', status: 'healthy', cpu: 45, memory: 62 },
      { name: 'Auth Service', status: 'healthy', cpu: 32, memory: 54 },
      { name: 'Database', status: 'warning', cpu: 78, memory: 81 },
      { name: 'Cache Layer', status: 'healthy', cpu: 23, memory: 41 }
    ]
  };
}

// API endpoint for dashboard data
app.get('/api/metrics', (req, res) => {
  res.json(getSampleData());
});

// Main dashboard page
app.get('/', (req, res) => {
  const data = getSampleData();
  const chartData = data.hourlyData.map(h => ({
    time: new Date(h.time).getHours() + ':00',
    requests: h.requests
  }));
  
  // Generate chart bars
  const maxRequests = Math.max(...chartData.map(x => x.requests));
  const chartBars = chartData.map((d, i) => {
    const heightPercent = (d.requests / maxRequests) * 100;
    const showLabel = i % 3 === 0;
    return `<div class="bar" style="height: ${heightPercent}%">
      ${showLabel ? `<div class="bar-label">${d.time}</div>` : ''}
    </div>`;
  }).join('');
  
  // Generate service items
  const serviceItems = data.services.map(svc => `
    <div class="service-item">
      <div class="service-name">${svc.name}</div>
      <span class="status-badge ${svc.status}">${svc.status}</span>
      <div class="service-metric">CPU: ${svc.cpu}%</div>
      <div class="service-metric">MEM: ${svc.memory}%</div>
    </div>
  `).join('');
  
  res.send(`<!doctype html>
  <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>OpsDashboard - Operations Overview</title>
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
          background: #f5f7fa;
          color: #333;
        }
        .header {
          background: #2c3e50;
          color: white;
          padding: 20px 24px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header h1 { font-size: 24px; font-weight: 600; }
        .container { padding: 24px; max-width: 1400px; margin: 0 auto; }
        
        .kpi-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 16px;
          margin-bottom: 24px;
        }
        .kpi-card {
          background: white;
          border-radius: 8px;
          padding: 20px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .kpi-card h3 {
          font-size: 14px;
          color: #666;
          font-weight: 500;
          margin-bottom: 8px;
        }
        .kpi-value {
          font-size: 32px;
          font-weight: 700;
          color: #2c3e50;
          margin-bottom: 4px;
        }
        .kpi-label {
          font-size: 12px;
          color: #999;
        }
        .status-healthy { color: #27ae60; }
        .status-warning { color: #f39c12; }
        .status-critical { color: #e74c3c; }
        
        .chart-section {
          background: white;
          border-radius: 8px;
          padding: 24px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
          margin-bottom: 24px;
        }
        .chart-section h2 {
          font-size: 18px;
          margin-bottom: 16px;
          color: #2c3e50;
        }
        .chart-container {
          height: 300px;
          position: relative;
        }
        .bar-chart {
          display: flex;
          align-items: flex-end;
          height: 100%;
          gap: 4px;
          padding: 10px 0;
        }
        .bar {
          flex: 1;
          background: linear-gradient(180deg, #3498db 0%, #2980b9 100%);
          border-radius: 4px 4px 0 0;
          position: relative;
          min-width: 8px;
          transition: opacity 0.2s;
        }
        .bar:hover { opacity: 0.8; cursor: pointer; }
        .bar-label {
          position: absolute;
          bottom: -20px;
          left: 50%;
          transform: translateX(-50%);
          font-size: 10px;
          color: #666;
          white-space: nowrap;
        }
        
        .services-section {
          background: white;
          border-radius: 8px;
          padding: 24px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .services-section h2 {
          font-size: 18px;
          margin-bottom: 16px;
          color: #2c3e50;
        }
        .service-item {
          display: flex;
          align-items: center;
          padding: 12px;
          border-bottom: 1px solid #eee;
        }
        .service-item:last-child { border-bottom: none; }
        .service-name {
          flex: 1;
          font-weight: 500;
        }
        .service-metric {
          margin-left: 16px;
          font-size: 12px;
          color: #666;
        }
        .status-badge {
          display: inline-block;
          padding: 4px 12px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
        }
        .status-badge.healthy {
          background: #d5f4e6;
          color: #27ae60;
        }
        .status-badge.warning {
          background: #fef5e7;
          color: #f39c12;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>📊 OpsDashboard</h1>
      </div>
      
      <div class="container">
        <div class="kpi-grid">
          <div class="kpi-card">
            <h3>Active Services</h3>
            <div class="kpi-value status-healthy">${data.overview.activeServices}</div>
            <div class="kpi-label">All systems operational</div>
          </div>
          
          <div class="kpi-card">
            <h3>Total Requests</h3>
            <div class="kpi-value">${(data.overview.totalRequests / 1000).toFixed(1)}k</div>
            <div class="kpi-label">Last 24 hours</div>
          </div>
          
          <div class="kpi-card">
            <h3>Error Rate</h3>
            <div class="kpi-value ${data.overview.errorRate > 1 ? 'status-warning' : 'status-healthy'}">
              ${data.overview.errorRate}%
            </div>
            <div class="kpi-label">Current period</div>
          </div>
          
          <div class="kpi-card">
            <h3>Avg Response Time</h3>
            <div class="kpi-value">${data.overview.avgResponseTime}ms</div>
            <div class="kpi-label">P50 latency</div>
          </div>
          
          <div class="kpi-card">
            <h3>Uptime</h3>
            <div class="kpi-value status-healthy">${data.overview.uptime}%</div>
            <div class="kpi-label">Last 7 days</div>
          </div>
          
          <div class="kpi-card">
            <h3>Open Incidents</h3>
            <div class="kpi-value ${data.overview.openIncidents > 5 ? 'status-critical' : 'status-warning'}">
              ${data.overview.openIncidents}
            </div>
            <div class="kpi-label">Requires attention</div>
          </div>
        </div>
        
        <div class="chart-section">
          <h2>Request Volume - Last 24 Hours</h2>
          <div class="chart-container">
            <div class="bar-chart">
              ${chartBars}
            </div>
          </div>
        </div>
        
        <div class="services-section">
          <h2>Service Health</h2>
          ${serviceItems}
        </div>
      </div>
      
      <script>
        // Auto-refresh every 30 seconds
        setTimeout(() => location.reload(), 30000);
      </script>
    </body>
  </html>`);
});

app.listen(port, () => {
  console.log(`✓ OpsDashboard running at http://localhost:${port}`);
  console.log(`✓ API endpoint available at http://localhost:${port}/api/metrics`);
});
