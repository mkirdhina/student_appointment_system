<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data["user_id"] ?? "";
$slot_id = $data["slot_id"] ?? "";
$purpose = trim($data["purpose"] ?? "");

if (empty($user_id) || empty($slot_id) || empty($purpose)) {
    echo json_encode([
        "success" => false,
        "message" => "User ID, slot ID, and purpose are required."
    ]);
    exit;
}

try {
    $conn->beginTransaction();

    // Check if user exists
    $userStmt = $conn->prepare("
        SELECT user_id
        FROM users
        WHERE user_id = ?
    ");
    $userStmt->execute([$user_id]);

    if (!$userStmt->fetch()) {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "User not found."
        ]);
        exit;
    }

    // Check if slot exists
    $slotStmt = $conn->prepare("
        SELECT slot_id, is_available
        FROM slots
        WHERE slot_id = ?
    ");
    $slotStmt->execute([$slot_id]);
    $slot = $slotStmt->fetch(PDO::FETCH_ASSOC);

    if (!$slot) {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "Slot not found."
        ]);
        exit;
    }

    // Check if slot is available
    if ((int)$slot["is_available"] !== 1) {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "This slot is already booked."
        ]);
        exit;
    }

    // Create appointment
    $appointmentStmt = $conn->prepare("
        INSERT INTO appointments (user_id, slot_id, purpose, status)
        VALUES (?, ?, ?, ?)
    ");
    $appointmentStmt->execute([
        $user_id,
        $slot_id,
        $purpose,
        "Booked"
    ]);

    $appointment_id = $conn->lastInsertId();

    // Mark slot as unavailable
    $updateSlotStmt = $conn->prepare("
        UPDATE slots
        SET is_available = 0
        WHERE slot_id = ?
    ");
    $updateSlotStmt->execute([$slot_id]);

    $conn->commit();

    echo json_encode([
        "success" => true,
        "message" => "Appointment booked successfully.",
        "appointment_id" => $appointment_id
    ]);

} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    echo json_encode([
        "success" => false,
        "message" => "Failed to book appointment.",
        "error" => $e->getMessage()
    ]);
}
?>