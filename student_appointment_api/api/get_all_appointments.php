<?php
require_once __DIR__ . "/../config/database.php";

$admin_user_id = $_GET["admin_user_id"] ?? "";

if (empty($admin_user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "Admin user ID is required."
    ]);
    exit;
}

try {
    // Check if the user is admin
    $adminStmt = $conn->prepare("
        SELECT user_id, role
        FROM users
        WHERE user_id = ?
    ");
    $adminStmt->execute([$admin_user_id]);
    $admin = $adminStmt->fetch(PDO::FETCH_ASSOC);

    if (!$admin || $admin["role"] !== "admin") {
        echo json_encode([
            "success" => false,
            "message" => "Access denied. Admin only."
        ]);
        exit;
    }

    // Get all appointments
    $stmt = $conn->prepare("
        SELECT 
            a.appointment_id,
            a.user_id,
            u.name AS student_name,
            u.username AS student_username,
            a.slot_id,
            a.purpose,
            a.status,
            a.created_at,
            s.lecturer_name,
            s.appointment_date,
            s.appointment_time,
            s.room
        FROM appointments a
        INNER JOIN users u ON a.user_id = u.user_id
        INNER JOIN slots s ON a.slot_id = s.slot_id
        ORDER BY a.created_at DESC
    ");

    $stmt->execute();
    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "message" => "All appointments retrieved successfully.",
        "data" => $appointments
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Failed to retrieve appointments.",
        "error" => $e->getMessage()
    ]);
}
?>