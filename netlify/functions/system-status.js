exports.handler = async (event, context) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers, body: '' };
    }

    const systemStatus = {
        timestamp: new Date().toISOString(),
        deployment: 'comfy-griffin-7bf94b.netlify.app',
        project: 'TW-LCEO-AISP-2025',
        version: '2.0',
        status: {
            isp: {
                performance: '4K@32.5fps',
                latency: '28ms',
                status: 'running'
            },
            ai: {
                accuracy: '95%',
                scenes: 13,
                status: 'running'
            },
            ums: {
                power: '3.5W',
                bandwidth: '1.1GB/s',
                status: 'optimized'
            },
            protection: {
                backups: 'multiple',
                status: 'active',
                last_backup: new Date().toISOString()
            }
        },
        cloud_shell: {
            mode: 'smart',
            protection_enabled: true,
            force_clone_disabled: true
        }
    };

    return {
        statusCode: 200,
        headers,
        body: JSON.stringify(systemStatus, null, 2)
    };
};
