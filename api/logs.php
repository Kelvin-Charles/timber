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
        // Get all logs or a specific log
        if(isset($_GET['id'])) {
            // Get specific log by ID
            $id = $_GET['id'];
            $query = "SELECT * FROM logs WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $log = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if($log) {
                echo json_encode($log);
            } else {
                http_response_code(404);
                echo json_encode(["message" => "Log not found"]);
            }
        } else {
            // Get all logs
            $query = "SELECT * FROM logs ORDER BY received_date DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode($logs);
        }
        break;
        
    case 'POST':
        // Add a new log
        $data = json_decode(file_get_contents("php://input"));
        
        if(
            !empty($data->log_number) &&
            !empty($data->species) &&
            !empty($data->diameter) &&
            !empty($data->length) &&
            !empty($data->quality) &&
            !empty($data->source) &&
            !empty($data->status) &&
            !empty($data->received_date)
        ) {
            $query = "INSERT INTO logs
                      (log_number, species, diameter, length, quality, source, status, received_date, notes)
                      VALUES
                      (:log_number, :species, :diameter, :length, :quality, :source, :status, :received_date, :notes)";
            
            $stmt = $conn->prepare($query);
            
            // Sanitize and bind parameters
            $log_number = htmlspecialchars(strip_tags($data->log_number));
            $species = htmlspecialchars(strip_tags($data->species));
            $diameter = htmlspecialchars(strip_tags($data->diameter));
            $length = htmlspecialchars(strip_tags($data->length));
            $quality = htmlspecialchars(strip_tags($data->quality));
            $source = htmlspecialchars(strip_tags($data->source));
            $status = htmlspecialchars(strip_tags($data->status));
            $received_date = htmlspecialchars(strip_tags($data->received_date));
            $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
            
            $stmt->bindParam(':log_number', $log_number);
            $stmt->bindParam(':species', $species);
            $stmt->bindParam(':diameter', $diameter);
            $stmt->bindParam(':length', $length);
            $stmt->bindParam(':quality', $quality);
            $stmt->bindParam(':source', $source);
            $stmt->bindParam(':status', $status);
            $stmt->bindParam(':received_date', $received_date);
            $stmt->bindParam(':notes', $notes);
            
            if($stmt->execute()) {
                $lastId = $conn->lastInsertId();
                
                // Fetch the newly created log
                $query = "SELECT * FROM logs WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $lastId);
                $stmt->execute();
                $log = $stmt->fetch(PDO::FETCH_ASSOC);
                
                http_response_code(201);
                echo json_encode($log);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to create log"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Unable to create log. Data is incomplete"]);
        }
        break;
        
    case 'PUT':
        // Update an existing log
        $data = json_decode(file_get_contents("php://input"));
        
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            if(
                !empty($data->log_number) &&
                !empty($data->species) &&
                !empty($data->diameter) &&
                !empty($data->length) &&
                !empty($data->quality) &&
                !empty($data->source) &&
                !empty($data->status) &&
                !empty($data->received_date)
            ) {
                $query = "UPDATE logs
                          SET log_number = :log_number,
                              species = :species,
                              diameter = :diameter,
                              length = :length,
                              quality = :quality,
                              source = :source,
                              status = :status,
                              received_date = :received_date,
                              notes = :notes
                          WHERE id = :id";
                
                $stmt = $conn->prepare($query);
                
                // Sanitize and bind parameters
                $log_number = htmlspecialchars(strip_tags($data->log_number));
                $species = htmlspecialchars(strip_tags($data->species));
                $diameter = htmlspecialchars(strip_tags($data->diameter));
                $length = htmlspecialchars(strip_tags($data->length));
                $quality = htmlspecialchars(strip_tags($data->quality));
                $source = htmlspecialchars(strip_tags($data->source));
                $status = htmlspecialchars(strip_tags($data->status));
                $received_date = htmlspecialchars(strip_tags($data->received_date));
                $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                
                $stmt->bindParam(':id', $id);
                $stmt->bindParam(':log_number', $log_number);
                $stmt->bindParam(':species', $species);
                $stmt->bindParam(':diameter', $diameter);
                $stmt->bindParam(':length', $length);
                $stmt->bindParam(':quality', $quality);
                $stmt->bindParam(':source', $source);
                $stmt->bindParam(':status', $status);
                $stmt->bindParam(':received_date', $received_date);
                $stmt->bindParam(':notes', $notes);
                
                if($stmt->execute()) {
                    // Fetch the updated log
                    $query = "SELECT * FROM logs WHERE id = :id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':id', $id);
                    $stmt->execute();
                    $log = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    http_response_code(200);
                    echo json_encode($log);
                } else {
                    http_response_code(500);
                    echo json_encode(["message" => "Unable to update log"]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["message" => "Unable to update log. Data is incomplete"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No log ID provided"]);
        }
        break;
        
    case 'DELETE':
        // Delete a log
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            $query = "DELETE FROM logs WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(["message" => "Log deleted successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to delete log"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No log ID provided"]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not allowed"]);
        break;
}
?> 