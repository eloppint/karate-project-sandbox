function fn() {
  var env = karate.env || 'qa';
  karate.log('karate.env =', env);

  var config = {
    baseUrl: 'https://mock-api.thankfulstone-b44cedd3.westus2.azurecontainerapps.io',
    apiKey: 'ibk-test-key-automation',
    channelId: 'API'
  };

  if (env === 'local') {
    config.baseUrl = 'http://localhost:3000';
  }

  // ---------- TDM (Test Data Management - Telecomunicaciones) ----------
  config.tdmUrl = 'https://demo-tdm-back.thankfulstone-b44cedd3.westus2.azurecontainerapps.io';   // TDM demo (FastAPI), sin auth
  config.tdmPhonePrefix = '+51';             // numero_serie Movil -> phone
  config.tdmUniquifyDoc = true;              // true = documentNumber/email unicos por corrida

  if (env === 'qa') {
    // TODO: reemplazar por la URL real del TDM desplegado cuando exista.
    config.tdmUrl = 'https://demo-tdm-back.thankfulstone-b44cedd3.westus2.azurecontainerapps.io';
    config.tdmUniquifyDoc = true;            // el mock de Azure persiste -> unicidad para re-ejecutar
  }

  // Common headers for authenticated endpoints (stored for reference)
  config.authHeaders = {
    'x-api-key': config.apiKey,
    'x-channel-id': config.channelId
  };

  // Set default headers — generates a fresh x-request-id per request.
  // Usa karate.get(...) (no el closure 'config') para que la funcion tambien
  // funcione dentro de features llamados (call read ...), donde 'config' no existe.
  karate.configure('headers', function() {
    return {
      'x-api-key': karate.get('apiKey'),
      'x-request-id': java.util.UUID.randomUUID().toString(),
      'x-channel-id': karate.get('channelId')
    };
  });

  // Timeouts (generous for cold-start containers)
  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 30000);

  // Disable SSL certificate validation for test environments
  karate.configure('ssl', true);

  return config;
}
