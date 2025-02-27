<?php
// Database configuration
$host = "localhost";
$db_name = "wood_management";
$username = "your_username";
$password = "your_password";

// Create database connection
try {
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
    die();
}
?> 