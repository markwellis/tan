<?php

error_reporting (E_ERROR | E_WARNING | E_PARSE | E_NOTICE);

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

define('IMAGE_UPLOAD_PATH', BASE_PATH . '/images/pics');
define('MAX_UPLOADED_PICTURE_SIZE', 2000000);
define('PROFILE_PICTURE_UPLOAD_PATH', BASE_PATH . '/sys/users/avatar');

/**
 * Site settings
 */
define('VERSION', '0.83.5');

define('DEBUG', false);
define('DEBUG_SQL', false);

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

define('ONE_HOUR', 3600);
define('ONE_MIN', 60);

/**
 * SQL settings
 */
define('SQL_SERVER', 'localhost');
define('SQL_USER', 'haha');
define('SQL_PASSW0RD', 'caBi2ieL');
define('SQL_DB', 'thisaintnews');

?>
