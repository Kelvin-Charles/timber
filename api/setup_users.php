<?php
// Include database configuration
require_once 'config.php';

// Define users to create
$users = [
    [
        'username' => 'admin',
        'email' => 'admin@ngaratimber.com',
        'password' => 'Admin123!',
        'role' => 'admin',
        'full_name' => 'Baraka Mwenda',
        'phone_number' => '+255 755 987 654',
        'profile_image' => null
    ],
    [
        'username' => 'director',
        'email' => 'director@ngaratimber.com',
        'password' => 'Director123!',
        'role' => 'director',
        'full_name' => 'Amani Ngara',
        'phone_number' => '+255 765 876 543',
        'profile_image' => null
    ],
    [
        'username' => 'manager',
        'email' => 'manager@ngaratimber.com',
        'password' => 'Manager123!',
        'role' => 'manager',
        'full_name' => 'Grace Mollel',
        'phone_number' => '+255 782 765 432',
        'profile_image' => null
    ],
    [
        'username' => 'worker',
        'email' => 'worker@ngaratimber.com',
        'password' => 'Worker123!',
        'role' => 'worker',
        'full_name' => 'Daniel Massawe',
        'phone_number' => '+255 745 654 321',
        'profile_image' => null
    ]
];

// HTML output
echo "<html><head><title>NgaraTimber User Setup</title>";
echo "<style>
    body { font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }
    h1 { color: #8B4513; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #8B4513; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .success { color: green; }
    .error { color: red; }
    .warning { color: orange; }
</style>";
echo "</head><body>";
echo "<h1>NgaraTimber User Setup</h1>";
echo "<table>";
echo "<tr><th>Username</th><th>Email</th><th>Role</th><th>Full Name</th><th>Status</th></tr>";

foreach ($users as $user) {
    // Check if user already exists
    $query = "SELECT * FROM users WHERE username = :username OR email = :email";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $user['username']);
    $stmt->bindParam(':email', $user['email']);
    $stmt->execute();
    
    echo "<tr>";
    echo "<td>{$user['username']}</td>";
    echo "<td>{$user['email']}</td>";
    echo "<td>{$user['role']}</td>";
    echo "<td>{$user['full_name']}</td>";
    
    if ($stmt->rowCount() > 0) {
        echo "<td class='warning'>Already exists</td>";
    } else {
        // Hash password
        $hashed_password = password_hash($user['password'], PASSWORD_DEFAULT);
        
        // Insert user
        $query = "INSERT INTO users (username, email, password, role, full_name, phone_number, profile_image) 
                  VALUES (:username, :email, :password, :role, :full_name, :phone_number, :profile_image)";
        
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':username', $user['username']);
        $stmt->bindParam(':email', $user['email']);
        $stmt->bindParam(':password', $hashed_password);
        $stmt->bindParam(':role', $user['role']);
        $stmt->bindParam(':full_name', $user['full_name']);
        $stmt->bindParam(':phone_number', $user['phone_number']);
        $stmt->bindParam(':profile_image', $user['profile_image']);
        
        if ($stmt->execute()) {
            echo "<td class='success'>Created successfully</td>";
        } else {
            echo "<td class='error'>Failed to create</td>";
        }
    }
    echo "</tr>";
}

echo "</table>";

echo "<h2>User Credentials</h2>";
echo "<p>The following credentials can be used to log in:</p>";
echo "<table>";
echo "<tr><th>Role</th><th>Username</th><th>Password</th></tr>";

foreach ($users as $user) {
    echo "<tr>";
    echo "<td>{$user['role']}</td>";
    echo "<td>{$user['username']}</td>";
    echo "<td>{$user['password']}</td>";
    echo "</tr>";
}

echo "</table>";
echo "<p><strong>IMPORTANT: Delete this file after use for security reasons.</strong></p>";
echo "</body></html>";
?> 