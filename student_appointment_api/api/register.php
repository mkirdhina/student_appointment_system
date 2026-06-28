<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$name = $data["name"] ?? "";
$username = $data["username"] ?? "";
$password = $data["password"] ?? "";

if (empty($name) || empty($username) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Name, portal username, and password are required."
    ]);
    exit;
}

if (!preg_match('/^[a-zA-Z0-9._-]{4,20}$/', $username)) {
    echo json_encode([
        "success" => false,
        "message" => "Portal username must be 4-20 characters and cannot contain spaces."
    ]);
    exit;
}

if (strlen($password) < 6) {
    echo json_encode([
        "success" => false,
        "message" => "Password must be at least 6 characters."
    ]);
    exit;
}

try {
    $checkStmt = $conn->prepare("SELECT * FROM users WHERE username = ?");
    $checkStmt->execute([$username]);

    if ($checkStmt->fetch()) {
        echo json_encode([
            "success" => false,
            "message" => "Portal username already registered."
        ]);
        exit;
    }

    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $conn->prepare("
        INSERT INTO users (name, username, password, role)
        VALUES (?, ?, ?, ?)
    ");

    $stmt->execute([$name, $username, $hashedPassword, "student"]);

    echo json_encode([
        "success" => true,
        "message" => "Registration successful."
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Registration failed.",
        "error" => $e->getMessage()
    ]);
}
?>