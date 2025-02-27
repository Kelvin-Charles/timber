<?php
// Include database configuration
require_once 'config.php';

// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Handle different HTTP methods
switch($method) {
    case 'GET':
        // Get all inventory items or a specific item
        if(isset($_GET['id'])) {
            // Get specific inventory item by ID
            $id = $_GET['id'];
            $query = "SELECT * FROM inventory WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $item = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if($item) {
                echo json_encode($item);
            } else {
                http_response_code(404);
                echo json_encode(["message" => "Inventory item not found"]);
            }
        } else {
            // Get all inventory items
            $query = "SELECT * FROM inventory ORDER BY name ASC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode($items);
        }
        break;
        
    case 'POST':
        // Add a new inventory item
        $data = json_decode(file_get_contents("php://input"));
        
        if(
            !empty($data->name) &&
            !empty($data->type) &&
            !empty($data->quantity) &&
            !empty($data->unit) &&
            !empty($data->status)
        ) {
            $query = "INSERT INTO inventory
                      (name, type, quantity, unit, price, location, status, description, image, last_updated)
                      VALUES
                      (:name, :type, :quantity, :unit, :price, :location, :status, :description, :image, NOW())";
            
            $stmt = $conn->prepare($query);
            
            // Sanitize and bind parameters
            $name = htmlspecialchars(strip_tags($data->name));
            $type = htmlspecialchars(strip_tags($data->type));
            $quantity = htmlspecialchars(strip_tags($data->quantity));
            $unit = htmlspecialchars(strip_tags($data->unit));
            $price = isset($data->price) ? htmlspecialchars(strip_tags($data->price)) : null;
            $location = isset($data->location) ? htmlspecialchars(strip_tags($data->location)) : null;
            $status = htmlspecialchars(strip_tags($data->status));
            $description = isset($data->description) ? htmlspecialchars(strip_tags($data->description)) : null;
            $image = isset($data->image) ? htmlspecialchars(strip_tags($data->image)) : null;
            
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':type', $type);
            $stmt->bindParam(':quantity', $quantity);
            $stmt->bindParam(':unit', $unit);
            $stmt->bindParam(':price', $price);
            $stmt->bindParam(':location', $location);
            $stmt->bindParam(':status', $status);
            $stmt->bindParam(':description', $description);
            $stmt->bindParam(':image', $image);
            
            if($stmt->execute()) {
                $lastId = $conn->lastInsertId();
                
                // Fetch the newly created inventory item
                $query = "SELECT * FROM inventory WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $lastId);
                $stmt->execute();
                $item = $stmt->fetch(PDO::FETCH_ASSOC);
                
                http_response_code(201);
                echo json_encode($item);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to create inventory item"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Unable to create inventory item. Data is incomplete"]);
        }
        break;
        
    case 'PUT':
        // Update an existing inventory item
        $data = json_decode(file_get_contents("php://input"));
        
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            if(
                !empty($data->name) &&
                !empty($data->type) &&
                !empty($data->quantity) &&
                !empty($data->unit) &&
                !empty($data->status)
            ) {
                $query = "UPDATE inventory
                          SET name = :name,
                              type = :type,
                              quantity = :quantity,
                              unit = :unit,
                              price = :price,
                              location = :location,
                              status = :status,
                              description = :description,
                              image = :image,
                              last_updated = NOW()
                          WHERE id = :id";
                
                $stmt = $conn->prepare($query);
                
                // Sanitize and bind parameters
                $name = htmlspecialchars(strip_tags($data->name));
                $type = htmlspecialchars(strip_tags($data->type));
                $quantity = htmlspecialchars(strip_tags($data->quantity));
                $unit = htmlspecialchars(strip_tags($data->unit));
                $price = isset($data->price) ? htmlspecialchars(strip_tags($data->price)) : null;
                $location = isset($data->location) ? htmlspecialchars(strip_tags($data->location)) : null;
                $status = htmlspecialchars(strip_tags($data->status));
                $description = isset($data->description) ? htmlspecialchars(strip_tags($data->description)) : null;
                $image = isset($data->image) ? htmlspecialchars(strip_tags($data->image)) : null;
                
                $stmt->bindParam(':id', $id);
                $stmt->bindParam(':name', $name);
                $stmt->bindParam(':type', $type);
                $stmt->bindParam(':quantity', $quantity);
                $stmt->bindParam(':unit', $unit);
                $stmt->bindParam(':price', $price);
                $stmt->bindParam(':location', $location);
                $stmt->bindParam(':status', $status);
                $stmt->bindParam(':description', $description);
                $stmt->bindParam(':image', $image);
                
                if($stmt->execute()) {
                    // Fetch the updated inventory item
                    $query = "SELECT * FROM inventory WHERE id = :id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':id', $id);
                    $stmt->execute();
                    $item = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    http_response_code(200);
                    echo json_encode($item);
                } else {
                    http_response_code(500);
                    echo json_encode(["message" => "Unable to update inventory item"]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["message" => "Unable to update inventory item. Data is incomplete"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No inventory item ID provided"]);
        }
        break;
        
    case 'DELETE':
        // Delete an inventory item
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            $query = "DELETE FROM inventory WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(["message" => "Inventory item deleted successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to delete inventory item"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No inventory item ID provided"]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not allowed"]);
        break;
}
?> 