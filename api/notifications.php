<?php
// Include database configuration
require_once 'config.php';

// Set headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get auth token from headers
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
$token = str_replace('Bearer ', '', $auth_header);

// Check if token is valid (implement your token validation logic here)
// For simplicity, we'll skip token validation in this example

// Handle GET request - get notifications
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        // Get user ID from token (implement your token decoding logic here)
        // For simplicity, we'll use a query parameter
        $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
        
        if (!$user_id) {
            http_response_code(400);
            echo json_encode(['error' => 'User ID is required']);
            exit();
        }
        
        // Get notifications for the user
        $query = "SELECT * FROM notifications WHERE user_id = :user_id OR user_id IS NULL ORDER BY created_at DESC";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();
        
        $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode($notifications);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
}

// Handle POST request - create notification
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Get request body
        $data = json_decode(file_get_contents('php://input'), true);
        
        // Validate required fields
        if (!isset($data['title']) || !isset($data['message']) || !isset($data['type'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Title, message, and type are required']);
            exit();
        }
        
        // Prepare data
        $title = $data['title'];
        $message = $data['message'];
        $type = $data['type'];
        $user_id = isset($data['user_id']) ? $data['user_id'] : null;
        $action_link = isset($data['action_link']) ? $data['action_link'] : null;
        $additional_data = isset($data['additional_data']) ? json_encode($data['additional_data']) : null;
        
        // Insert notification
        $query = "INSERT INTO notifications (title, message, type, user_id, action_link, additional_data) 
                  VALUES (:title, :message, :type, :user_id, :action_link, :additional_data)";
        
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':title', $title);
        $stmt->bindParam(':message', $message);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':action_link', $action_link);
        $stmt->bindParam(':additional_data', $additional_data);
        
        $stmt->execute();
        
        // Get the inserted notification
        $notification_id = $conn->lastInsertId();
        
        $query = "SELECT * FROM notifications WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $notification_id);
        $stmt->execute();
        
        $notification = $stmt->fetch(PDO::FETCH_ASSOC);
        
        http_response_code(201);
        echo json_encode($notification);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
}

// Handle PUT request - mark notification as read
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    try {
        // Get notification ID from URL
        $notification_id = isset($_GET['id']) ? $_GET['id'] : null;
        
        if (!$notification_id) {
            http_response_code(400);
            echo json_encode(['error' => 'Notification ID is required']);
            exit();
        }
        
        // Update notification
        $query = "UPDATE notifications SET is_read = 1 WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $notification_id);
        $stmt->execute();
        
        // Get the updated notification
        $query = "SELECT * FROM notifications WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $notification_id);
        $stmt->execute();
        
        $notification = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$notification) {
            http_response_code(404);
            echo json_encode(['error' => 'Notification not found']);
            exit();
        }
        
        echo json_encode($notification);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
}

// Handle DELETE request - delete notification
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    try {
        // Get notification ID from URL
        $notification_id = isset($_GET['id']) ? $_GET['id'] : null;
        
        if (!$notification_id) {
            http_response_code(400);
            echo json_encode(['error' => 'Notification ID is required']);
            exit();
        }
        
        // Delete notification
        $query = "DELETE FROM notifications WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $notification_id);
        $stmt->execute();
        
        echo json_encode(['success' => true]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
}
?> 