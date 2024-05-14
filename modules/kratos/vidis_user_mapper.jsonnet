local claims = std.extVar('claims');

local enshortenUuid(uuid) = std.split(uuid, '-')[0];

local extractFromClaims = function(fieldName)
  if fieldName in claims then claims[fieldName] else null;

local mapRoleToInterest = function(role)
  if role == 'LEHR' then 'teacher'
  else if role == 'LERN' then 'pupil'
  else 'other';

local buildUsername = function()
  local acronym = extractFromClaims('akronym');
  local uuid = extractFromClaims('sub');
  local firstName = extractFromClaims('firstName');
  local familyName = extractFromClaims('familyName');

  if acronym != '' && acronym != null then acronym + enshortenUuid(uuid)
  else if firstName != '' && firstName != null &&
          familyName != null && familyName != ''
  then firstName + familyName + enshortenUuid(uuid)
  else enshortenUuid(uuid);

{
  identity: {
    traits: {
      email: claims.sub + '@vidis.schule',
      username: buildUsername(),
      interest: if 'rolle' in claims then mapRoleToInterest(claims.rolle) else 'other',
    },
  },
}
