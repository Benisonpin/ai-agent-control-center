const fetch = require('node-fetch');

const CTE_AGENT_ENDPOINT = process.env.CTE_AGENT_ENDPOINT || 'https://8000-cs-default-default.cloudshell.dev';

exports.handler = async (event, context) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Content-Type': 'application/json'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    console.log('CTE Agent Endpoint:', CTE_AGENT_ENDPOINT);
    console.log('Request method:', event.httpMethod);
    
    if (event.httpMethod === 'POST') {
      const commandData = JSON.parse(event.body);
      console.log('Forwarding command:', commandData);
      
      const response = await fetch(`${CTE_AGENT_ENDPOINT}/api/broadcast`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(commandData),
        timeout: 10000
      });
      
      if (!response.ok) {
        throw new Error(`CTE Agent responded with ${response.status}: ${response.statusText}`);
      }
      
      const result = await response.json();
      console.log('CTE Agent response:', result);
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          ...result,
          source: 'cte_agent_via_cloudshell',
          timestamp: new Date().toISOString()
        })
      };
    }
    
    if (event.httpMethod === 'GET') {
      console.log('Fetching status from CTE Agent');
      
      const response = await fetch(`${CTE_AGENT_ENDPOINT}/api/status`, {
        timeout: 8000
      });
      
      if (!response.ok) {
        throw new Error(`Status endpoint responded with ${response.status}: ${response.statusText}`);
      }
      
      const status = await response.json();
      console.log('Status response:', status);
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          ...status,
          source: 'cte_agent_via_cloudshell',
          cloud_shell_connected: status.active_sessions > 0,
          endpoint: CTE_AGENT_ENDPOINT
        })
      };
    }
    
    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
    
  } catch (error) {
    console.error('Error connecting to CTE Agent:', error);
    
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        status: 'error',
        message: 'CTE AI Agent 暫時無法連接',
        error: error.message,
        source: 'netlify_fallback',
        cloud_shell_connected: false,
        active_sessions: 0,
        total_commands: 0,
        timestamp: new Date().toISOString(),
        endpoint: CTE_AGENT_ENDPOINT
      })
    };
  }
};
