<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$lecturer_name = $data["lecturer_name"] ?? "";
$appointment_date = $data["appointment_date"] ?? "";
$appointment_time = $data["appointment_time"] ?? "";
$room = $data["room"] ?? "";

if (empty($lecturer_name) || empty($appointment_date) || empty($appointment_time) || empty($room)) {
    echo json_encode([
        "success" => false,
        "message" => "Lecturer name, date, time, and room are required."
    ]);
    exit;
}

try {
    $stmt = $conn->prepare("
        INSERT INTO slots 
        (lecturer_name, appointment_date, appointment_time, room, is_available)
        VALUES (?, ?, ?, ?, ?)
    ");

    $stmt->execute([
        $lecturer_name,
        $appointment_date,
        $appointment_time,
        $room,
        1
    ]);

    echo json_encode([
        "success" => true,
        "message" => "Consultation slot added successfully."
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Failed to add slot. Slot may already exist.",
        "error" => $e->getMessage()
    ]);
}
?>