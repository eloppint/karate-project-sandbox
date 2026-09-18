@HU-001 @health @smoke @api
Feature: Health Check API — GET /health

  Background:
    * url baseUrl

  @TC-1 @CA-01 @smoke @happypath
  Scenario: GET /health — Retorna 200 con status UP
    Given path 'health'
    When method GET
    Then status 200
    And match response.status == 'UP'
    And match response.service == 'ibk-mock-api'
    And match response.version == '1.0.0'

  @TC-2 @CA-02 @regression @contract
  Scenario: GET /health — Estructura completa de respuesta
    Given path 'health'
    When method GET
    Then status 200
    And match response == read('schemas/health-response.json')

  @TC-3 @CA-03 @smoke @security
  Scenario: GET /health — No requiere autenticación
    # Explicitly do NOT send any auth headers
    * configure headers = null
    Given path 'health'
    When method GET
    Then status 200
    And match response.status == 'UP'

  @TC-4 @CA-04 @regression @performance
  Scenario: GET /health — Response time menor a 5 segundos
    Given path 'health'
    When method GET
    Then status 200
    And assert responseTime < 5000
