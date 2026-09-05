-- ══════════════════════════════════════════════════════════════
-- NexChat — Database Setup Script
-- Complete and synchronized schema for NexChat MVC application.
-- ══════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS chat_app
    CHARACTER SET utf8mb4
    COLLATE       utf8mb4_unicode_ci;

USE chat_app;

-- ── Users ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    avatar_color VARCHAR(7)   DEFAULT '#00a884',
    is_online    TINYINT(1)   DEFAULT 0,
    last_seen    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Messages ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    sender_id    INT          NOT NULL,
    receiver_id  INT          NOT NULL,
    message      TEXT         NOT NULL,
    message_type ENUM('text','image','file') DEFAULT 'text',
    file_path    VARCHAR(500) DEFAULT NULL,
    is_read      TINYINT(1)   DEFAULT 0,
    reaction     VARCHAR(20)  DEFAULT NULL,
    created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id)   REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_conv    (sender_id, receiver_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Typing Status ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS typing_status (
    user_id    INT NOT NULL,
    to_user_id INT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, to_user_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Pinned Chats ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pinned_chats (
    user_id    INT NOT NULL,
    contact_id INT NOT NULL,
    pinned_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, contact_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
