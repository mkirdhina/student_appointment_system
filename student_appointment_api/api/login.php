<?php
require_once __DIR__ . "/../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$username = $data["username"] ?? "";
$password = $data["password"] ?? "";

if (empty($username) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Portal username and password are required."
    ]);
    exit;
}

try {
    $stmt = $conn->prepare("
        SELECT user_id, name, username, password, role 
        FROM users 
        WHERE username = ?
    ");

    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode([
            "success" => false,
            "message" => "User not found."
        ]);
        exit;
    }

    if (!password_verify($password, $user["password"])) {
        echo json_encode([
            "success" => false,
            "message" => "Incorrect password."
        ]);
        exit;
    }

    echo json_encode([
        "success" => true,
        "message" => "Login successful.",
        "data" => [
            "user_id" => $user["user_id"],
            "name" => $user["name"],
            "username" => $user["username"],
            "role" => $user["role"]
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Login failed.",
        "error" => $e->getMessage()
    ]);
}
?>