@HU-002 @customers @api @negative
Feature: Customers API — Negative & Security Cases

  Background:
    * url baseUrl

  @TC-4 @CA-04 @smoke @security
  Scenario: GET /api/v1/customers/{id} — Sin x-api-key retorna 401
    * configure headers = null
    Given path 'api', 'v1', 'customers', 'a1b2c3d4-0001-4000-8000-000000000001'
    When method GET
    Then status 401
    And match response.error == '#present'

  @TC-5 @CA-05 @regression @security
  Scenario: GET /api/v1/customers/{id} — API key invalida retorna 401
    * configure headers = null
    Given path 'api', 'v1', 'customers', 'a1b2c3d4-0001-4000-8000-000000000001'
    And header x-api-key = 'invalid-key-12345'
    And header x-request-id = java.util.UUID.randomUUID().toString()
    And header x-channel-id = 'API'
    When method GET
    Then status 401
    And match response.error == '#present'

  @TC-6 @CA-06 @regression @negative
  Scenario: POST /api/v1/customers — Sin documentNumber retorna 400
    Given path 'api', 'v1', 'customers'
    And request
      """
      {
        "firstName": "Incompleto",
        "lastName": "Sin DNI",
        "documentType": "DNI",
        "email": "incompleto@test.com",
        "phone": "+51999000111"
      }
      """
    When method POST
    Then status 400
    And match response.error == '#present'

  @TC-7 @CA-06 @regression @negative
  Scenario: POST /api/v1/customers — Sin firstName retorna 400
    Given path 'api', 'v1', 'customers'
    And request
      """
      {
        "lastName": "Solo Apellido",
        "documentType": "DNI",
        "documentNumber": "11223344",
        "email": "solo.apellido@test.com",
        "phone": "+51999000222"
      }
      """
    When method POST
    Then status 400
    And match response.error == '#present'

  @TC-8 @CA-07 @regression @negative
  Scenario: GET /api/v1/customers/{id} — ID inexistente retorna 404
    Given path 'api', 'v1', 'customers', '00000000-0000-0000-0000-000000000000'
    When method GET
    Then status 404
    And match response.error == '#present'

  @TC-10 @CA-03 @CA-07 @regression @negative
  Scenario: PATCH /api/v1/customers/{id} — ID inexistente retorna 404
    Given path 'api', 'v1', 'customers', '00000000-0000-0000-0000-000000000000'
    And request { "phone": "+51999999999" }
    When method PATCH
    Then status 404
    And match response.error == '#present'
