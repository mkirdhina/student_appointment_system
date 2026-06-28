<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$appointment_id = $data["appointment_id"] ?? "";
$user_id = $data["user_id"] ?? "";
$purpose = trim($data["purpose"] ?? "");

if (empty($appointment_id) || empty($user_id) || empty($purpose)) {
    echo json_encode([
        "success" => false,
        "message" => "Appointment ID, user ID, and purpose are required."
    ]);
    exit;
}

try {
    // Check if appointment exists and belongs to this user
    $checkStmt = $conn->prepare("
        SELECT appointment_id, status
        FROM appointments
        WHERE appointment_id = ? AND user_id = ?
    ");
    $checkStmt->execute([$appointment_id, $user_id]);
    $appointment = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$appointment) {
        echo json_encode([
            "success" => false,
            "message" => "Appointment not found."
        ]);
        exit;
    }

    if ($appointment["status"] === "Cancelled") {
        echo json_encode([
            "success" => false,
            "message" => "Cancelled appointment cannot be updated."
        ]);
        exit;
    }

    // Update appointment purpose
    $stmt = $conn->prepare("
        UPDATE appointments
        SET purpose = ?
        WHERE appointment_id = ? AND user_id = ?
    ");

    $stmt->execute([$purpose, $appointment_id, $user_id]);

    echo json_encode([
        "success" => true,
        "message" => "Appointment updated successfully."
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update appointment.",
        "error" => $e->getMessage()
    ]);
}
?>