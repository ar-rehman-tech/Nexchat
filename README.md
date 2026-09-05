# NexChat — Real-Time Chat Application

NexChat is a modern, responsive, real-time messaging web application built with native PHP and MySQL following a clean MVC (Model-View-Controller) architecture. It features instant conversation polling, typing indicators, read receipts, emoji reactions, message search, pinned chats, and secure file sharing with dark and light themes.

---

## 🚀 Technology Stack & System Requirements

- **Backend:** PHP 8.0+ (PHP 8.2+ recommended)
- **Database:** MySQL 5.7+ or MariaDB 10.4+
- **Frontend:** Vanilla JavaScript (ES6+), GSAP for animations, Phosphor Icons
- **Web Server:** Apache 2.4+ (with `mod_rewrite` enabled) or Nginx
- **PHP Extensions Required:**
  - `mysqli`
  - `fileinfo` (for server-side MIME type verification)
  - `gd` (for image validation and processing)
  - `session`
  - `json`
  - `mbstring`

---

## 📁 Project Structure

```text
nexchat/
├── app/
│   ├── Controllers/
│   │   ├── ApiController.php      # Authenticated JSON API endpoints
│   │   ├── AuthController.php     # Login, registration, session management
│   │   └── ChatController.php     # Main chat application view controller
│   ├── Core/
│   │   ├── Controller.php         # Base controller with view and response helpers
│   │   ├── Csrf.php               # Centralized CSRF generation and validation
│   │   ├── Database.php           # Database singleton with safe error handling
│   │   ├── Env.php                # Environment variable parser for .env
│   │   ├── RateLimiter.php        # Lightweight abuse throttling mechanism
│   │   └── Router.php             # URL routing and HTTP method dispatcher
│   ├── Models/
│   │   ├── Message.php            # Message storage, retrieval, reactions, search
│   │   └── User.php               # User registration, authentication, presence
│   └── Views/
│       ├── auth/
│       │   ├── login.php          # Sign-in page
│       │   └── register.php       # Account creation page
│       ├── chat/
│       │   └── index.php          # Main chat interface
│       └── layouts/
│           └── auth.php           # Authentication layout
├── assets/
│   ├── css/
│   │   ├── auth.css               # Authentication styling
│   │   └── chat.css               # Main chat styling & responsive rules
│   ├── js/
│   │   └── chat.js                # Chat logic, polling, DOM safety, AJAX
│   └── uploads/
│       ├── .gitkeep
│       └── .htaccess              # Protects upload directory from script execution
├── legacy/                        # Archived procedural implementation (protected)
│   ├── README.md
│   └── .htaccess
├── .env.example                   # Configuration template with placeholders
├── .gitignore                     # Git rules (excludes .env and user uploads)
├── .htaccess                      # Root rewrite engine to index.php
├── database.sql                   # Initial database schema setup script
├── database_migration.sql         # Non-destructive upgrade script for existing DBs
├── index.php                      # Application front controller
└── README.md                      # Project documentation
```

---

## 🛠️ Installation & Setup Guide

### 1. Place Project in Web Root
Clone or place the project folder inside your local web server root directory:
- **XAMPP Windows:** `D:\xampp\htdocs\nexchat` or `C:\xampp\htdocs\nexchat`
- **Linux/Apache:** `/var/www/html/nexchat`

### 2. Configure Environment (.env)
Copy `.env.example` to `.env` in the project root:
```bash
cp .env.example .env
```
Edit `.env` to match your local database credentials:
```ini
APP_NAME=NexChat
APP_ENV=development
APP_DEBUG=false
APP_URL=http://localhost/nexchat

DB_HOST=localhost
DB_PORT=3306
DB_NAME=chat_app
DB_USER=root
DB_PASS=

SESSION_LIFETIME=86400
```

### 3. Import Database Schema
Import `database.sql` into MySQL using phpMyAdmin, the MySQL command line, or MySQL Workbench:
```bash
mysql -u root -p < database.sql
```
*Note: If upgrading an existing database without destroying data, run `database_migration.sql`.*

### 4. Configure Uploads Directory
Ensure `assets/uploads/` is writable by the web server user:
```bash
chmod 755 assets/uploads
```
Uploaded files are stored with randomly generated hex filenames, and execution of PHP/scripts inside `assets/uploads/` is blocked via `assets/uploads/.htaccess`.

### 5. Access the Application
Open your web browser and navigate to:
```text
http://localhost/nexchat/
```
You will be redirected to the login page (`/login`). Create a new account at `/register` to begin chatting.

---

## 🔒 Security Architecture

- **Authentication & Passwords:** Uses PHP's `password_hash()` (default Bcrypt) and `password_verify()`. On successful login, `session_regenerate_id(true)` prevents session fixation attacks.
- **Centralized CSRF Protection:** All state-changing requests (`POST /login`, `POST /register`, `POST /api/*`) require a cryptographically secure token (`random_bytes(32)`) validated via `hash_equals()`. The frontend transmits tokens via `X-CSRF-Token` headers and FormData.
- **SQL Injection Prevention:** 100% of database queries handling dynamic data use prepared statements with strict parameter binding (`mysqli_stmt::bind_param`).
- **XSS Defense:** Output is sanitized using `htmlspecialchars(..., ENT_QUOTES, 'UTF-8')` server-side, and client-side message rendering utilizes strict `textContent` DOM nodes and HTML entity escaping.
- **Upload Hardening:** Multi-layer validation enforcing size limits (max 10MB), client MIME verification, server-side MIME inspection via `finfo_file()`, image dimension validation via `getimagesize()`, cryptographically randomized filenames, and `.htaccess` script execution prevention.
- **Abuse Protection:** Session/IP-based throttling on authentication endpoints, messaging, and uploads.
- **Legacy Isolation:** Older procedural scripts in `legacy/` are archived and blocked from public web requests via Apache `.htaccess` redirection.

---

## 📡 API Overview

| Method | Endpoint | Description | Auth Required | CSRF Required |
|---|---|---|---|---|
| `GET` | `/api/users` | List contacts, online status, last message, unread count | Yes | No |
| `GET` | `/api/messages?contact_id={id}` | Retrieve conversation history & mark read | Yes | No |
| `GET` | `/api/search?contact_id={id}&q={term}` | Search messages within a conversation | Yes | No |
| `POST` | `/api/send` | Send text message (`receiver_id`, `message`) | Yes | Yes |
| `POST` | `/api/upload` | Upload photo or document attachment (`multipart`) | Yes | Yes |
| `POST` | `/api/typing` | Broadcast typing status (`to_user_id`) | Yes | Yes |
| `POST` | `/api/reaction` | Add or clear emoji reaction (`message_id`, `reaction`) | Yes | Yes |
| `POST` | `/api/pin` | Pin/unpin contact (`contact_id`, `pin`) | Yes | Yes |
| `POST` | `/api/read` | Explicitly mark incoming messages as read | Yes | Yes |

---

## 🔧 Troubleshooting

- **404 Not Found on routes (`/login`, `/register`, `/api/...`):**
  Ensure Apache `mod_rewrite` is enabled and `.htaccess` overrides are permitted (`AllowOverride All` in Apache configuration).
- **Database Connection Refused:**
  Ensure MySQL/MariaDB service is running on the host and port specified in `.env`.
- **Uploads failing:**
  Verify that the `assets/uploads/` directory exists and has write permissions for the web server user. Check that `upload_max_filesize` and `post_max_size` in `php.ini` allow at least 10MB.
