/**
 * Auto-filtrado TDM -> payload de POST /api/v1/customers.
 * Extrae SOLO los 6 campos que la API bancaria necesita.
 * args: { u: UsuarioDetalle, prefix: string, uniqueSuffix: string }
 */
function (args) {
  var u = args.u;
  var prefix = args.prefix || '+51';
  var suffix = args.uniqueSuffix || '';        // '' = modo fiel (documento tal cual)

  // lastName = apellido_paterno + apellido_materno
  var lastName = ((u.apellido_paterno || '') + ' ' + (u.apellido_materno || '')).trim();

  // phone: primer servicio Movil disponible; si no hay, fallback deterministico
  var phone = null;
  var servicios = u.servicios || [];
  for (var i = 0; i < servicios.length; i++) {
    if (servicios[i].tipo === 'Movil' && servicios[i].numero_serie) {
      phone = prefix + servicios[i].numero_serie;
      break;
    }
  }
  if (phone == null) {
    var digits = ('' + u.documento).replace(/\D/g, '');
    while (digits.length < 9) { digits = '9' + digits; }
    phone = prefix + digits.substring(digits.length - 9);
  }

  var documentNumber = '' + u.documento + suffix;
  var email = suffix ? ('tdm.' + u.documento + suffix + '@teleandes-demo.pe') : u.correo;

  return {
    firstName: u.nombres,
    lastName: lastName,
    documentType: u.tipo_documento,   // DNI | CE (compatibles con la API bancaria)
    documentNumber: documentNumber,
    email: email,
    phone: phone
  };
}
