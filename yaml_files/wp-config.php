<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'root' );

/** MySQL database password */
define( 'DB_PASSWORD', '' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define('FS_METHOD', 'direct');
/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
/**
 * Followings keys were generated using: curl -s https://api.wordpress.org/secret-key/1.1/salt/
 */
define('AUTH_KEY',         'z`H2O$@7Z6hI|kivPTtn;1llz$G::`GlHoc`@f*nc0Nw7ma8B>/.J1$cH!pf=l._');
define('SECURE_AUTH_KEY',  ']+*3;]4C%C;-U>-|P}a4%}%2-b-7UKHw;b3fx.6X{S-/.ATjcJ5PG+;&#=o1|wq&');
define('LOGGED_IN_KEY',    '+?>?;!M,ztC5kn+m1~E;MSbm)^}gRJ2i j;y|+X#n%[c{)=;IaoB~WU+^8NSFZYD');
define('NONCE_KEY',        'LqF^Gp=>R|oH8Y6K={h%FeN)|m+O!_Ixrh&dJxFL}V@.n.:D(gF(h/ON2oi1c>_#');
define('AUTH_SALT',        'G,roXpa-S4pMEr`jBj$YAre#g mBGe#j;+F-vO4};qQdD||1hFLT<)IPe|%}3/&~');
define('SECURE_AUTH_SALT', ',|b2KDxY-X<FFV+Oj?B`b9DbGJTIArf(~qWN{HNxQT2C]pt-s7O<r>QN#K8G16j[');
define('LOGGED_IN_SALT',   '<F[/(m;/EIJM=VgaMGN~XfX!8}K~8m|k-e`.-I$YI+5$cDh<jz05+|rjj$E$mI2C');
define('NONCE_SALT',       '=b,*GB3gXC;,8fVG5)^KUbZ;3MZ.>0 c|:POMs9;=_h$2|5hw`MDF/S7X+Q+_2v7');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
