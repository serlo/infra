local claims = std.extVar('claims');

local enshortenUuid(uuid) = std.split(uuid, '-')[0];

local mapRoleToInterest = function(role)
  if role == 'LEHR' then 'teacher'
  else if role == 'LERN' then 'pupil'
  else 'other';

local buildUsername = function(uuid, acronym, firstName, familyName)
  if acronym != '' && acronym != null then acronym + enshortenUuid(uuid)
  else if firstName != '' && firstName != null &&
          familyName != null && familyName != ''
  then firstName + familyName + enshortenUuid(uuid)
  else enshortenUuid(uuid);

{
  identity: {
    traits: {
      email: claims.sub + '@vidis.schule',
      username: buildUsername(claims.sub, claims.akronym, claims.vorname, claims.nachname),
      interest: mapRoleToInterest(claims.rolle),
    },
  },
}
