-- ══════════════════════════════════════════════════════════════
-- NexChat — Safe Schema Migration Script
-- Adds missing columns and tables to existing installations without
-- dropping tables or truncating data.
-- ══════════════════════════════════════════════════════════════

USE chat_app;

-- ── Users: Ensure avatar_color exists ─────────────────────────
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_color VARCHAR(7) DEFAULT '#00a884';

-- ── Messages: Ensure message_type, file_path, reaction exist ──
ALTER TABLE messages ADD COLUMN IF NOT EXISTS message_type ENUM('text','image','file') DEFAULT 'text';
ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_path VARCHAR(500) DEFAULT NULL;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS reaction VARCHAR(20) DEFAULT NULL;

-- ── Typing Status: Ensure table exists ────────────────────────
CREATE TABLE IF NOT EXISTS typing_status (
    user_id    INT NOT NULL,
    to_user_id INT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, to_user_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Pinned Chats: Ensure table exists ─────────────────────────
CREATE TABLE IF NOT EXISTS pinned_chats (
    user_id    INT NOT NULL,
    contact_id INT NOT NULL,
    pinned_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, contact_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
