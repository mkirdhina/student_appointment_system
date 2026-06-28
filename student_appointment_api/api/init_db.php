<?php
require_once __DIR__ . "/../config/database.php";

try {
    // USERS TABLE
    $conn->exec("
        CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'student',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ");

    // SLOTS TABLE
    $conn->exec("
        CREATE TABLE IF NOT EXISTS slots (
            slot_id INTEGER PRIMARY KEY AUTOINCREMENT,
            lecturer_name TEXT NOT NULL,
            appointment_date TEXT NOT NULL,
            appointment_time TEXT NOT NULL,
            room TEXT NOT NULL,
            is_available INTEGER NOT NULL DEFAULT 1,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(lecturer_name, appointment_date, appointment_time)
        )
    ");

    // APPOINTMENTS TABLE
    $conn->exec("
        CREATE TABLE IF NOT EXISTS appointments (
            appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            slot_id INTEGER NOT NULL,
            purpose TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Booked',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(user_id),
            FOREIGN KEY (slot_id) REFERENCES slots(slot_id)
        )
    ");

    // Insert sample users only if users table is empty
    $userCountStmt = $conn->query("SELECT COUNT(*) FROM users");
    $userCount = $userCountStmt->fetchColumn();

    if ($userCount == 0) {
        $studentPassword = password_hash("123456", PASSWORD_DEFAULT);
        $adminPassword = password_hash("admin123", PASSWORD_DEFAULT);

        $userStmt = $conn->prepare("
            INSERT INTO users (name, username, password, role)
            VALUES (?, ?, ?, ?)
        ");

        $userStmt->execute(["Test Student", "s307267", $studentPassword, "student"]);
        $userStmt->execute(["Admin User", "admin", $adminPassword, "admin"]);
    }

    // Insert sample slots only if slots table is empty
    $slotCountStmt = $conn->query("SELECT COUNT(*) FROM slots");
    $slotCount = $slotCountStmt->fetchColumn();

    if ($slotCount == 0) {
        $slotStmt = $conn->prepare("
            INSERT INTO slots 
            (lecturer_name, appointment_date, appointment_time, room, is_available)
            VALUES (?, ?, ?, ?, ?)
        ");

        $slotStmt->execute(["Dr. Aina", "2026-07-01", "10:00 AM", "Room 101", 1]);
        $slotStmt->execute(["Dr. Aina", "2026-07-01", "2:00 PM", "Room 101", 1]);
        $slotStmt->execute(["Dr. Hakim", "2026-07-02", "11:00 AM", "Room 204", 1]);
        $slotStmt->execute(["Dr. Mei", "2026-07-03", "9:30 AM", "Room 305", 1]);
        $slotStmt->execute(["Dr. Sarah", "2026-07-04", "3:00 PM", "Room 210", 1]);
    }

    echo json_encode([
        "success" => true,
        "message" => "Database initialized safely. No existing data was deleted."
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database setup failed.",
        "error" => $e->getMessage()
    ]);
}
?>