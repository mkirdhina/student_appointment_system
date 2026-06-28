<?php
require_once __DIR__ . "/../config/database.php";

try {
    $stmt = $conn->prepare("
        SELECT 
            slot_id,
            lecturer_name,
            appointment_date,
            appointment_time,
            room,
            is_available
        FROM slots
        WHERE is_available = 1
        ORDER BY appointment_date, appointment_time
    ");

    $stmt->execute();
    $slots = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "success" => true,
        "message" => "Available slots retrieved successfully.",
        "data" => $slots
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Failed to retrieve slots.",
        "error" => $e->getMessage()
    ]);
}
?>