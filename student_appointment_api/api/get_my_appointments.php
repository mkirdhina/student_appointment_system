<?php
require_once __DIR__ . "/../config/database.php";

$user_id = $_GET["user_id"] ?? "";

if (empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID is required."
    ]);
    exit;
}

try {
    $stmt = $conn->prepare("
        SELECT 
            a.appointment_id,
            a.user_id,
            a.slot_id,
            a.purpose,
            a.status,
            a.created_at,
            s.lecturer_name,
            s.appointment_date,
            s.appointment_time,
            s.room
        FROM appointments a
        INNER JOIN slots s ON a.slot_id = s.slot_id
        WHERE a.user_id = ?
        ORDER BY a.created_at DESC
    ");

    $stmt->execute([$user_id]);
    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "message" => "Appointments retrieved successfully.",
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