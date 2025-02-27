<?php
// Include database configuration
require_once 'config.php';

// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
    exit();
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

if (
    !isset($data->username) || 
    !isset($data->email) || 
    !isset($data->password) || 
    !isset($data->role)
) {
    http_response_code(400);
    echo json_encode(["message" => "Required fields are missing"]);
    exit();
}

// Sanitize input
$username = htmlspecialchars(strip_tags($data->username));
$email = htmlspecialchars(strip_tags($data->email));
$password = htmlspecialchars(strip_tags($data->password));
$role = htmlspecialchars(strip_tags($data->role));
$fullName = isset($data->full_name) ? htmlspecialchars(strip_tags($data->full_name)) : null;
$phoneNumber = isset($data->phone_number) ? htmlspecialchars(strip_tags($data->phone_number)) : null;
$profileImage = isset($data->profile_image) ? htmlspecialchars(strip_tags($data->profile_image)) : null;

// Check if username or email already exists
$query = "SELECT * FROM users WHERE username = :username OR email = :email";
$stmt = $conn->prepare($query);
$stmt->bindParam(':username', $username);
$stmt->bindParam(':email', $email);
$stmt->execute();

if ($stmt->rowCount() > 0) {
    http_response_code(409);
    echo json_encode(["message" => "Username or email already exists"]);
    exit();
}

// Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$query = "INSERT INTO users (username, email, password, role, full_name, phone_number, profile_image) 
          VALUES (:username, :email, :password, :role, :full_name, :phone_number, :profile_image)";

$stmt = $conn->prepare($query);
$stmt->bindParam(':username', $username);
$stmt->bindParam(':email', $email);
$stmt->bindParam(':password', $hashed_password);
$stmt->bindParam(':role', $role);
$stmt->bindParam(':full_name', $fullName);
$stmt->bindParam(':phone_number', $phoneNumber);
$stmt->bindParam(':profile_image', $profileImage);

if ($stmt->execute()) {
    $lastId = $conn->lastInsertId();
    
    // Fetch the newly created user
    $query = "SELECT id, username, email, role, full_name, phone_number, profile_image 
              FROM users WHERE id = :id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $lastId);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    http_response_code(201);
    echo json_encode($user);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Unable to register user"]);
}
?> 