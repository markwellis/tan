<?php
/**
 * Directory settings
 */
define('BASE_PATH', $_SERVER['DOCUMENT_ROOT']);
define('SYS_PATH', BASE_PATH . '/sys');
define('LIB_PATH', BASE_PATH . '/lib');
define('MODEL_PATH', LIB_PATH . '/models');

define('THEME_NAME', 'classic');
define('THEME_PATH', LIB_PATH .  '/themes');
define('THEME_HTTP', "http://{$_SERVER['HTTP_HOST']}/" . basename(LIB_PATH) .'/themes/' . THEME_NAME);
define('TEMPLATE_PATH', THEME_PATH . '/' . THEME_NAME . '/templates');

define('PICTURE_PATH', BASE_PATH .'/images/pics');
define('RESIZE_CACHE_PATH', BASE_PATH . '/images/cache/resize');

define('OLD_CODE_PATH', BASE_PATH . '/code');
define('THIRD_PARTY_PATH', LIB_PATH . '/3rdparty');

/**
 * Site settings
 */
define('VERSION', '0.80a');

define('DEBUG', TRUE);
define('DEBUG_SQL', FALSE);

define('PROMOTED_CUTOFF', 10);
define('SALT', '13f76tfvtf43x68fd');
define('OBJECT_LIMIT', 27);
define('MAGIC', true);
define('SESSION_NAME', '62duihsfd8923rj21ws');

/**
 * Recaptcha settings
 */
define('RECAPTCHA_PUBLIC_KEY', '6LfOtQIAAAAAAKjR5kiq9YLFjG80_bLST2fB696F');
define('RECAPTCHA_PRIVATE_KEY', '6LfOtQIAAAAAAK0DnRYVGRWVP0aBtfG158_OYGok');

/**
 * Memcache host settings 
 */
define('MEMCACHE_HOST', '127.0.0.1');
define('MEMCACHE_PORT', 11211);
define('LONG_CACHE', 36000); // 10 hours
define('MEDIUM_CACHE', 10800); // 3 hours
define('SHORT_CACHE', 3600); // 1 hour

/**
 * SQL settings
 */
define('SQL_SERVER', 'localhost');
define('SQL_USER', 'haha');
define('SQL_PASSW0RD', 'caBi2ieL');
define('SQL_DB', 'thisaintnews');

?>
