<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit;
}

$db_folder = __DIR__ . "/../db";

if (!is_dir($db_folder)) {
    mkdir($db_folder, 0777, true);
}

$db_path = $db_folder . "/appointments.db";

try {
    $conn = new PDO("sqlite:" . $db_path);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Help prevent database locked error
    $conn->exec("PRAGMA busy_timeout = 5000;");
    $conn->exec("PRAGMA foreign_keys = ON;");

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed.",
        "path" => $db_path,
        "error" => $e->getMessage()
    ]);
    exit;
}
?>