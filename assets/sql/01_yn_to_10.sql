UPDATE comments SET deleted = 1 WHERE deleted = 'Y';
UPDATE comments SET deleted = 0 WHERE deleted = 'N';

UPDATE object SET nsfw = 1 WHERE nsfw = 'Y';
UPDATE object SET nsfw = 0 WHERE nsfw = 'N';
UPDATE object SET deleted = 1 WHERE deleted = 'Y';
UPDATE object SET deleted = 0 WHERE deleted = 'N';

UPDATE user SET confirmed = 1 WHERE confirmed = 'Y';
UPDATE user SET confirmed = 0 WHERE confirmed = 'N';
UPDATE user SET deleted = 1 WHERE deleted = 'Y';
UPDATE user SET deleted = 0 WHERE deleted = 'N';

UPDATE cms SET deleted = 1 WHERE deleted = 'Y';
UPDATE cms SET deleted = 0 WHERE deleted = 'N';
UPDATE cms SET system = 1 WHERE system = 'Y';
UPDATE cms SET system = 0 WHERE system = 'N';
UPDATE cms SET nowrapper = 1 WHERE nowrapper = 'Y';
UPDATE cms SET nowrapper = 0 WHERE nowrapper = 'N';

UPDATE lotto SET confirmed = 1 WHERE confirmed = 'Y';
UPDATE lotto SET confirmed = 0 WHERE confirmed = 'N';
UPDATE lotto SET winner = 1 WHERE winner = 'y';
UPDATE lotto SET winner = 0 WHERE winner = 'n';
