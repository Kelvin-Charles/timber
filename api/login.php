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

if (!isset($data->username) || !isset($data->password)) {
    http_response_code(400);
    echo json_encode(["message" => "Username and password are required"]);
    exit();
}

// Sanitize input
$username = htmlspecialchars(strip_tags($data->username));
$password = htmlspecialchars(strip_tags($data->password));

// Check if user exists
$query = "SELECT * FROM users WHERE username = :username";
$stmt = $conn->prepare($query);
$stmt->bindParam(':username', $username);
$stmt->execute();

if ($stmt->rowCount() > 0) {
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Verify password
    if (password_verify($password, $user['password'])) {
        // Generate JWT token
        $token = bin2hex(random_bytes(32)); // Simple token for demonstration
        
        // In a production environment, use a proper JWT library
        // and include expiration, user ID, and role in the token
        
        // Return user data with token
        $user_data = [
            'id' => (int)$user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'role' => $user['role'],
            'full_name' => $user['full_name'],
            'phone_number' => $user['phone_number'],
            'profile_image' => $user['profile_image'],
            'token' => $token
        ];
        
        http_response_code(200);
        echo json_encode($user_data);
    } else {
        http_response_code(401);
        echo json_encode(["message" => "Invalid credentials"]);
    }
} else {
    http_response_code(401);
    echo json_encode(["message" => "Invalid credentials"]);
}
?> 