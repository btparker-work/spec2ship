# OpsDashboard

A lightweight operations dashboard for monitoring system health, performance metrics, and service status.

## Features

- **Overview Page**: Real-time KPI summaries including active services, request volume, error rates, response times, uptime, and incidents
- **Sample Data Source**: Simulated metrics with hourly request patterns over 24 hours
- **Chart Visualization**: Bar chart showing request volume trends
- **Service Health Monitor**: Status display for individual services with CPU and memory metrics
- **REST API**: JSON endpoint for programmatic access to metrics

## Quick Start

### Prerequisites

- Node.js 18+ (with ES modules support)
- npm or yarn

### Installation

```bash
npm install
```

### Running the Dashboard

```bash
npm start
```

The dashboard will be available at: **http://localhost:3000**

### Configuration

Set the port via environment variable:

```bash
PORT=8080 npm start
```

## API Endpoints

### GET /
Main dashboard UI with visualizations

### GET /api/metrics
Returns JSON with current metrics:

```json
{
  "overview": {
    "activeServices": 12,
    "totalRequests": 245678,
    "errorRate": "0.87",
    "avgResponseTime": 184,
    "uptime": 99.95,
    "openIncidents": 3
  },
  "hourlyData": [...],
  "services": [...]
}
```

## Architecture

**Stack:**
- Node.js with Express
- ES modules
- Zero build step - pure server-side rendering
- Embedded CSS and minimal client-side JavaScript

**Data Flow:**
```
Client Browser
    ↓ HTTP GET /
Express Server
    ↓ calls
getSampleData()
    ↓ returns
Simulated Metrics
    ↓ rendered in
HTML Template
    ↓ sent to
Client Browser (Dashboard UI)
```

## Customization

### Adding Real Data Sources

Replace the `getSampleData()` function in `server.js` with calls to your actual monitoring systems:

```javascript
async function getRealData() {
  const metrics = await prometheusClient.query('...');
  const incidents = await pagerdutyClient.getIncidents();
  // Transform and return
}
```

### Styling

CSS is embedded in the HTML template. Modify the `<style>` section in `server.js` to customize colors, layouts, or add new components.

### Adding Charts

The current implementation uses pure CSS bar charts. For more advanced visualizations, consider adding:
- Chart.js (lightweight)
- D3.js (powerful but heavier)
- Plotly (interactive)

## Production Considerations

- **Security**: Add authentication middleware (e.g., express-basic-auth)
- **Performance**: Enable caching headers, use Redis for metric storage
- **Reliability**: Add health check endpoint, implement circuit breakers for external data sources
- **Monitoring**: Integrate with logging (Winston, Pino) and APM tools
- **Scaling**: Run behind a reverse proxy (nginx), use PM2 for process management

## Development

### Project Structure

```
OpsDashboard/
├── server.js       # Express server and dashboard logic
├── package.json    # Dependencies and scripts
└── README.md       # This file
```

### Auto-Refresh

The dashboard automatically refreshes every 30 seconds. Disable by removing the `setTimeout` in the client-side script block.

## License

MIT

## Support

For issues or questions, refer to the Spec2Ship documentation or open an issue in the repository.

---

**Built with Spec2Ship** - Automated software development lifecycle framework
