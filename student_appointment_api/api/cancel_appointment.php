<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$appointment_id = $data["appointment_id"] ?? "";
$user_id = $data["user_id"] ?? "";

if (empty($appointment_id) || empty($user_id)) {
    echo json_encode([
        "success" => false,
        "message" => "Appointment ID and user ID are required."
    ]);
    exit;
}

try {
    $conn->beginTransaction();

    // Check if appointment exists and belongs to this user
    $checkStmt = $conn->prepare("
        SELECT appointment_id, slot_id, status
        FROM appointments
        WHERE appointment_id = ? AND user_id = ?
    ");
    $checkStmt->execute([$appointment_id, $user_id]);
    $appointment = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$appointment) {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "Appointment not found."
        ]);
        exit;
    }

    if ($appointment["status"] === "Cancelled") {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "Appointment is already cancelled."
        ]);
        exit;
    }

    // Change appointment status to Cancelled
    $cancelStmt = $conn->prepare("
        UPDATE appointments
        SET status = ?
        WHERE appointment_id = ? AND user_id = ?
    ");
    $cancelStmt->execute(["Cancelled", $appointment_id, $user_id]);

    // Make the slot available again
    $slotStmt = $conn->prepare("
        UPDATE slots
        SET is_available = 1
        WHERE slot_id = ?
    ");
    $slotStmt->execute([$appointment["slot_id"]]);

    $conn->commit();

    echo json_encode([
        "success" => true,
        "message" => "Appointment cancelled successfully."
    ]);

} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    echo json_encode([
        "success" => false,
        "message" => "Failed to cancel appointment.",
        "error" => $e->getMessage()
    ]);
}
?>