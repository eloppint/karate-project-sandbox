@HU-002 @customers @api
Feature: Customers CRUD — Happy Path

  Background:
    * url baseUrl

  @TC-1 @CA-01 @smoke @happypath
  Scenario: POST /api/v1/customers — Crear cliente con datos validos
    * def uniqueDoc = '' + java.lang.System.currentTimeMillis()
    Given path 'api', 'v1', 'customers'
    And request
      """
      {
        "firstName": "Carlos",
        "lastName": "Test Automation",
        "documentType": "DNI",
        "documentNumber": "#(uniqueDoc)",
        "email": "carlos.test@automation.com",
        "phone": "+51999888777"
      }
      """
    When method POST
    Then status 201
    And match response.customerId == '#uuid'
    And match response.firstName == 'Carlos'
    And match response.lastName == 'Test Automation'
    And match response.documentType == 'DNI'
    And match response.documentNumber == uniqueDoc
    And match response.status == 'ACTIVE'

  @TC-2 @CA-02 @smoke @happypath @contract
  Scenario: GET /api/v1/customers/{id} — Consultar cliente pre-seeded
    Given path 'api', 'v1', 'customers', 'a1b2c3d4-0001-4000-8000-000000000001'
    When method GET
    Then status 200
    And match response.customerId == 'a1b2c3d4-0001-4000-8000-000000000001'
    And match response.documentNumber == '12345678'
    And match response.firstName == '#string'
    And match response.accounts == '#array'
    And match response contains read('schemas/customer-response.json')

  @TC-3 @CA-03 @regression @happypath
  Scenario: PATCH /api/v1/customers/{id} — Actualizar campo parcial
    # First GET to capture current state
    Given path 'api', 'v1', 'customers', 'a1b2c3d4-0001-4000-8000-000000000001'
    When method GET
    Then status 200
    * def originalFirstName = response.firstName
    * def originalDoc = response.documentNumber

    # PATCH only phone
    Given path 'api', 'v1', 'customers', 'a1b2c3d4-0001-4000-8000-000000000001'
    And request { "phone": "+51911222333" }
    When method PATCH
    Then status 200
    And match response.phone == '+51911222333'
    And match response.firstName == originalFirstName
    And match response.documentNumber == originalDoc

  @TC-9 @CA-01 @CA-02 @regression @e2e
  Scenario: E2E — Crear cliente y luego consultarlo
    # Generate unique doc number to avoid 409 on re-runs
    * def uniqueDoc = 'E2E' + java.lang.System.currentTimeMillis()

    # Step 1: Create
    Given path 'api', 'v1', 'customers'
    And request { "firstName": "E2E", "lastName": "Test Flow", "documentType": "CE", "documentNumber": "#(uniqueDoc)", "email": "e2e.flow@test.com", "phone": "+51900111222" }
    When method POST
    Then status 201
    * def createdId = response.customerId

    # Step 2: Retrieve and verify
    Given path 'api', 'v1', 'customers', createdId
    When method GET
    Then status 200
    And match response.firstName == 'E2E'
    And match response.documentNumber == uniqueDoc

  @TC-11 @CA-08 @tdm @regression
  Scenario Outline: POST /api/v1/customers — Crear cliente con datos desde TDM (por ID)
    # 1) Sufijo de unicidad (segun config) para permitir re-ejecucion
    * def suffix = tdmUniquifyDoc ? ('' + java.lang.System.currentTimeMillis()).substring(7) : ''

    # 2) Recuperar el usuario del TDM y auto-filtrar los campos utiles
    * def tdm = call read('classpath:com/demo/qa/tdm/tdm.feature@getById') { id: '<tdmId>', suffix: '#(suffix)' }
    * def payload = tdm.customer
    * print 'Payload construido desde TDM:', payload

    # 3) Crear el cliente en la API bancaria con esos datos
    Given path 'api', 'v1', 'customers'
    And request payload
    When method POST
    Then status 201
    And match response.customerId == '#uuid'
    And match response.firstName == payload.firstName
    And match response.lastName == payload.lastName
    And match response.documentType == payload.documentType
    And match response.documentNumber == payload.documentNumber
    And match response.email == payload.email
    And match response.phone == payload.phone
    And match response.status == 'ACTIVE'

    Examples:
      | tdmId |
      | 3     |
      | 5     |

  @TC-12 @CA-08 @tdm @e2e
  Scenario: E2E TDM — Reservar Libre, asignar Movil, crear cliente y liberar
    # 1) Buscar un usuario disponible (estado Libre)
    * def busqueda = call read('classpath:com/demo/qa/tdm/tdm.feature@buscarLibre')
    * assert busqueda.libres.length > 0
    * def tdmId = busqueda.libres[0].id

    # Teardown garantizado: liberar el usuario aunque el escenario falle
    * configure afterScenario = function(){ if (karate.get('tdmId')) karate.call('classpath:com/demo/qa/tdm/tdm.feature@liberar', { id: karate.get('tdmId') }) }

    # 2) Reservar en exclusiva para esta corrida
    * call read('classpath:com/demo/qa/tdm/tdm.feature@reservar') { id: '#(tdmId)', reusable: false }

    # 3) Asignar una linea Movil NUEVA (de aqui sale un phone real)
    * def svc = call read('classpath:com/demo/qa/tdm/tdm.feature@servicio') { id: '#(tdmId)', tipo: 'Movil', generarNuevo: true }

    # 4) Recuperar detalle (ya con el servicio), mapear y crear cliente
    * def suffix = ('' + java.lang.System.currentTimeMillis()).substring(7)
    * def tdm = call read('classpath:com/demo/qa/tdm/tdm.feature@getById') { id: '#(tdmId)', suffix: '#(suffix)' }
    * def payload = tdm.customer

    Given path 'api', 'v1', 'customers'
    And request payload
    When method POST
    Then status 201
    And match response.customerId == '#uuid'
    And match response.phone == payload.phone
    And match response.status == 'ACTIVE'
    # (el paso 5 — liberar — lo ejecuta afterScenario)
