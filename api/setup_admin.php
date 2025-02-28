<?php
// Include database configuration
require_once 'config.php';

// Admin user details
$username = "admin";
$email = "admin@ngaratimber.com";
$password = "Admin123!"; // You should change this to a strong password
$role = "admin";
$fullName = "NgaraTimber Administrator";
$phoneNumber = null;
$profileImage = null;

// Check if admin already exists
$query = "SELECT * FROM users WHERE username = :username OR email = :email";
$stmt = $conn->prepare($query);
$stmt->bindParam(':username', $username);
$stmt->bindParam(':email', $email);
$stmt->execute();

if ($stmt->rowCount() > 0) {
    echo "Admin user already exists!";
    exit();
}

// Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert admin user
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
    echo "Admin user created successfully!";
    echo "<br><br>";
    echo "Username: " . $username . "<br>";
    echo "Password: " . $password . "<br>";
    echo "Role: " . $role . "<br>";
    echo "<br>";
    echo "<strong>Please delete this file after use for security reasons.</strong>";
} else {
    echo "Failed to create admin user.";
}
?> 