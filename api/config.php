<?php
// Database configuration
$host = 'localhost';
$db_name = 'furatahm_timber';
$username = 'furatahm_timber';
$password = 'furatahm_timber';
$charset = 'utf8mb4';

// Set error reporting for development
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// PDO connection options
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

// Connection string (DSN)
$dsn = "mysql:host=$host;dbname=$db_name;charset=$charset";

try {
    // Create PDO instance
    $conn = new PDO($dsn, $username, $password, $options);
} catch (PDOException $e) {
    // If connection fails
    die(json_encode([
        "status" => "error",
        "message" => "Connection failed: " . $e->getMessage()
    ]));
}
?> 