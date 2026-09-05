<?php
/**
 * NexChat — Main entry point
 */

// ── Secure Session Configuration ─────────────────────────────────────
if (session_status() === PHP_SESSION_NONE) {
    $isSecure = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ||
                (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443);

    session_set_cookie_params([
        'lifetime' => 86400,
        'path'     => '/',
        'domain'   => '',
        'secure'   => $isSecure,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    session_start();
}

// ── Base URL Detection ───────────────────────────────────────────────
$scriptDir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME']));
define('BASE_URL', ($scriptDir === '/' || $scriptDir === '.') ? '' : rtrim($scriptDir, '/'));

// ── Core ─────────────────────────────────────────────────────────────
require_once __DIR__ . '/app/Core/Env.php';
require_once __DIR__ . '/app/Core/Csrf.php';
require_once __DIR__ . '/app/Core/RateLimiter.php';
require_once __DIR__ . '/app/Core/Database.php';
require_once __DIR__ . '/app/Core/Router.php';
require_once __DIR__ . '/app/Core/Controller.php';

// ── Models ───────────────────────────────────────────────────────────
require_once __DIR__ . '/app/Models/User.php';
require_once __DIR__ . '/app/Models/Message.php';

// ── Controllers ──────────────────────────────────────────────────────
require_once __DIR__ . '/app/Controllers/AuthController.php';
require_once __DIR__ . '/app/Controllers/ChatController.php';
require_once __DIR__ . '/app/Controllers/ApiController.php';

// ── Boot DB ──────────────────────────────────────────────────────────
\App\Core\Database::init();

// ── Router ───────────────────────────────────────────────────────────
$router = new \App\Core\Router();

// Web Routes
$router->get('/',          'ChatController@index');
$router->get('/login',     'AuthController@loginForm');
$router->post('/login',    'AuthController@login');
$router->get('/register',  'AuthController@registerForm');
$router->post('/register', 'AuthController@register');
$router->get('/logout',    'AuthController@logout');

// API Routes
$router->get('/api/users',     'ApiController@users');
$router->get('/api/messages',  'ApiController@messages');
$router->get('/api/search',    'ApiController@search');
$router->post('/api/send',     'ApiController@send');
$router->post('/api/upload',   'ApiController@upload');
$router->post('/api/typing',   'ApiController@typing');
$router->post('/api/read',     'ApiController@markRead');
$router->post('/api/reaction', 'ApiController@reaction');
$router->post('/api/pin',      'ApiController@pin');

// Dispatch
$requestPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
if (defined('BASE_URL') && BASE_URL !== '' && str_starts_with($requestPath, BASE_URL)) {
    $requestPath = substr($requestPath, strlen(BASE_URL));
}
$url = isset($_GET['url']) ? '/' . ltrim($_GET['url'], '/') : ($requestPath ?: '/');
$router->dispatch($url);
