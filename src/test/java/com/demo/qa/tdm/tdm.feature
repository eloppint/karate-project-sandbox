@ignore @tdm
Feature: TDM — Cliente reutilizable de Test Data Management

  # Feature @ignore: no corre solo; se invoca por tag desde otros features:
  #   call read('classpath:com/demo/qa/tdm/tdm.feature@<accion>') { ...args... }

  Background:
    * url tdmUrl
    # El TDM demo no requiere autenticacion; tolera headers extra.
    # NO se tocan los headers para no afectar el estado del feature que invoca (POST bancario).

  # -------- Recuperar por ID + auto-filtrar a payload de cliente --------
  # args: id (int, requerido), suffix (string, opcional para unicidad)
  @getById
  Scenario: GET /api/usuarios/{id} — recuperar y mapear a cliente
    Given path 'api', 'usuarios', id
    When method GET
    Then status 200
    * def tdmUser = response
    * def mapper = read('classpath:com/demo/qa/tdm/map-usuario-to-customer.js')
    * def customer = mapper({ u: tdmUser, prefix: tdmPhonePrefix, uniqueSuffix: karate.get('suffix', '') })

  # -------- Buscar usuarios en estado Libre --------
  @buscarLibre
  Scenario: GET /api/usuarios?estado=Libre — listar disponibles
    Given path 'api', 'usuarios'
    And param estado = 'Libre'
    When method GET
    Then status 200
    * def libres = response.items
    * def total = response.total

  # -------- Reservar -------- args: id (req), reusable (opcional, default true)
  @reservar
  Scenario: PATCH /api/usuarios/{id}/reservar
    * def reusableFlag = karate.get('reusable', true)
    Given path 'api', 'usuarios', id, 'reservar'
    And request { reusable: '#(reusableFlag)' }
    When method PATCH
    Then status 200
    * def tdmUser = response

  # -------- Asignar servicio (p.ej. Movil -> phone) --------
  # args: id (req), tipo (opcional 'Movil'), generarNuevo (opcional true)
  @servicio
  Scenario: POST /api/usuarios/{id}/servicios
    * def tipoServicio = karate.get('tipo', 'Movil')
    * def nuevo = karate.get('generarNuevo', true)
    Given path 'api', 'usuarios', id, 'servicios'
    And request { tipo: '#(tipoServicio)', generar_nuevo: '#(nuevo)' }
    When method POST
    Then status 201
    * def servicio = response

  # -------- Liberar (teardown) -------- args: id (req)
  @liberar
  Scenario: PATCH /api/usuarios/{id}/liberar
    Given path 'api', 'usuarios', id, 'liberar'
    When method PATCH
    Then status 200
    * def tdmUser = response
