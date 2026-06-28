<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$admin_user_id = $data["admin_user_id"] ?? "";
$appointment_id = $data["appointment_id"] ?? "";
$purpose = trim($data["purpose"] ?? "");
$status = trim($data["status"] ?? "");

if (empty($admin_user_id) || empty($appointment_id) || empty($purpose) || empty($status)) {
    echo json_encode([
        "success" => false,
        "message" => "Admin user ID, appointment ID, purpose, and status are required."
    ]);
    exit;
}

$allowedStatuses = ["Booked", "Cancelled"];

if (!in_array($status, $allowedStatuses)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid status. Status must be Booked or Cancelled."
    ]);
    exit;
}

try {
    $conn->beginTransaction();

    // Check if the user is admin
    $adminStmt = $conn->prepare("
        SELECT user_id, role
        FROM users
        WHERE user_id = ?
    ");
    $adminStmt->execute([$admin_user_id]);
    $admin = $adminStmt->fetch(PDO::FETCH_ASSOC);

    if (!$admin || $admin["role"] !== "admin") {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "Access denied. Admin only."
        ]);
        exit;
    }

    // Check if appointment exists
    $appointmentStmt = $conn->prepare("
        SELECT appointment_id, slot_id
        FROM appointments
        WHERE appointment_id = ?
    ");
    $appointmentStmt->execute([$appointment_id]);
    $appointment = $appointmentStmt->fetch(PDO::FETCH_ASSOC);

    if (!$appointment) {
        $conn->rollBack();
        echo json_encode([
            "success" => false,
            "message" => "Appointment not found."
        ]);
        exit;
    }

    // Update appointment
    $updateStmt = $conn->prepare("
        UPDATE appointments
        SET purpose = ?, status = ?
        WHERE appointment_id = ?
    ");
    $updateStmt->execute([$purpose, $status, $appointment_id]);

    // Keep slot availability consistent with appointment status
    if ($status === "Cancelled") {
        $slotAvailable = 1;
    } else {
        $slotAvailable = 0;
    }

    $slotStmt = $conn->prepare("
        UPDATE slots
        SET is_available = ?
        WHERE slot_id = ?
    ");
    $slotStmt->execute([$slotAvailable, $appointment["slot_id"]]);

    $conn->commit();

    echo json_encode([
        "success" => true,
        "message" => "Appointment updated successfully by admin."
    ]);

} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    echo json_encode([
        "success" => false,
        "message" => "Failed to update appointment.",
        "error" => $e->getMessage()
    ]);
}
?>