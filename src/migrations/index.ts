import * as migration_20261012_094046 from './20261012_094046';
import * as migration_20261025_080057_member_photo from './20261025_080057_member_photo';
import * as migration_20261104_142455_audit_roles_tokens from './20261104_142455_audit_roles_tokens';

export const migrations = [
  {
    up: migration_20261012_094046.up,
    down: migration_20261012_094046.down,
    name: '20261012_094046',
  },
  {
    up: migration_20261025_080057_member_photo.up,
    down: migration_20261025_080057_member_photo.down,
    name: '20261025_080057_member_photo',
  },
  {
    up: migration_20261104_142455_audit_roles_tokens.up,
    down: migration_20261104_142455_audit_roles_tokens.down,
    name: '20261104_142455_audit_roles_tokens'
  },
];
