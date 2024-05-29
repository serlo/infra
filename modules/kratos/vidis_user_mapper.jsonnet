local claims = std.extVar('claims');

local enshortenUuid(uuid) = std.split(uuid, '-')[0];

local extractFromClaims = function(fieldName)
  if fieldName in claims then claims[fieldName] else null;

local uuid = extractFromClaims('sub');

local buildEmail = function()
  local email = extractFromClaims('email');

  if email != '' && email != null
  then email
  else enshortenUuid(uuid) + '@fakeemail.vidis';

local buildUsername = function()
  local preferredUsername = extractFromClaims('preferred_username');

  if preferredUsername != '' && preferredUsername != null
  then preferredUsername + '-' + enshortenUuid(uuid)
  else enshortenUuid(uuid);

{
  identity: {
    traits: {
      email: buildEmail(),
      username: buildUsername(),
      interest: 'other',
    },
  },
}
