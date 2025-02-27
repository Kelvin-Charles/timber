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
        // Get all productions or a specific production
        if(isset($_GET['id'])) {
            // Get specific production by ID
            $id = $_GET['id'];
            
            // Get production details
            $query = "SELECT * FROM productions WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $production = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if($production) {
                // Get logs used in this production
                $query = "SELECT l.* FROM logs l
                          JOIN production_logs pl ON l.id = pl.log_id
                          WHERE pl.production_id = :production_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':production_id', $id);
                $stmt->execute();
                $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                // Add logs to production data
                $production['used_logs'] = array_map(function($log) {
                    return $log['id'];
                }, $logs);
                
                echo json_encode($production);
            } else {
                http_response_code(404);
                echo json_encode(["message" => "Production not found"]);
            }
        } else {
            // Get all productions
            $query = "SELECT * FROM productions ORDER BY start_date DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $productions = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // For each production, get the logs used
            foreach($productions as &$production) {
                $query = "SELECT log_id FROM production_logs WHERE production_id = :production_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':production_id', $production['id']);
                $stmt->execute();
                $logs = $stmt->fetchAll(PDO::FETCH_COLUMN);
                
                $production['used_logs'] = $logs;
            }
            
            echo json_encode($productions);
        }
        break;
        
    case 'POST':
        // Add a new production
        $data = json_decode(file_get_contents("php://input"));
        
        if(
            !empty($data->product_name) &&
            !empty($data->current_stage) &&
            !empty($data->start_date) &&
            !empty($data->status) &&
            isset($data->completion_percentage)
        ) {
            // Start transaction
            $conn->beginTransaction();
            
            try {
                $query = "INSERT INTO productions
                          (product_name, current_stage, start_date, end_date, assigned_to, status, notes, completion_percentage)
                          VALUES
                          (:product_name, :current_stage, :start_date, :end_date, :assigned_to, :status, :notes, :completion_percentage)";
                
                $stmt = $conn->prepare($query);
                
                // Sanitize and bind parameters
                $product_name = htmlspecialchars(strip_tags($data->product_name));
                $current_stage = htmlspecialchars(strip_tags($data->current_stage));
                $start_date = htmlspecialchars(strip_tags($data->start_date));
                $end_date = isset($data->end_date) ? htmlspecialchars(strip_tags($data->end_date)) : null;
                $assigned_to = isset($data->assigned_to) ? htmlspecialchars(strip_tags($data->assigned_to)) : null;
                $status = htmlspecialchars(strip_tags($data->status));
                $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                $completion_percentage = htmlspecialchars(strip_tags($data->completion_percentage));
                
                $stmt->bindParam(':product_name', $product_name);
                $stmt->bindParam(':current_stage', $current_stage);
                $stmt->bindParam(':start_date', $start_date);
                $stmt->bindParam(':end_date', $end_date);
                $stmt->bindParam(':assigned_to', $assigned_to);
                $stmt->bindParam(':status', $status);
                $stmt->bindParam(':notes', $notes);
                $stmt->bindParam(':completion_percentage', $completion_percentage);
                
                $stmt->execute();
                $production_id = $conn->lastInsertId();
                
                // Add logs to production if provided
                if(isset($data->used_logs) && is_array($data->used_logs)) {
                    foreach($data->used_logs as $log_id) {
                        $query = "INSERT INTO production_logs (production_id, log_id) VALUES (:production_id, :log_id)";
                        $stmt = $conn->prepare($query);
                        $stmt->bindParam(':production_id', $production_id);
                        $stmt->bindParam(':log_id', $log_id);
                        $stmt->execute();
                    }
                }
                
                // Commit transaction
                $conn->commit();
                
                // Fetch the newly created production
                $query = "SELECT * FROM productions WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $production_id);
                $stmt->execute();
                $production = $stmt->fetch(PDO::FETCH_ASSOC);
                
                // Add logs to response
                $production['used_logs'] = $data->used_logs ?? [];
                
                http_response_code(201);
                echo json_encode($production);
            } catch(Exception $e) {
                // Rollback transaction on error
                $conn->rollBack();
                http_response_code(500);
                echo json_encode(["message" => "Unable to create production: " . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Unable to create production. Data is incomplete"]);
        }
        break;
        
    case 'PUT':
        // Update an existing production
        $data = json_decode(file_get_contents("php://input"));
        
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            if(
                !empty($data->product_name) &&
                !empty($data->current_stage) &&
                !empty($data->start_date) &&
                !empty($data->status) &&
                isset($data->completion_percentage)
            ) {
                // Start transaction
                $conn->beginTransaction();
                
                try {
                    $query = "UPDATE productions
                              SET product_name = :product_name,
                                  current_stage = :current_stage,
                                  start_date = :start_date,
                                  end_date = :end_date,
                                  assigned_to = :assigned_to,
                                  status = :status,
                                  notes = :notes,
                                  completion_percentage = :completion_percentage
                              WHERE id = :id";
                    
                    $stmt = $conn->prepare($query);
                    
                    // Sanitize and bind parameters
                    $product_name = htmlspecialchars(strip_tags($data->product_name));
                    $current_stage = htmlspecialchars(strip_tags($data->current_stage));
                    $start_date = htmlspecialchars(strip_tags($data->start_date));
                    $end_date = isset($data->end_date) ? htmlspecialchars(strip_tags($data->end_date)) : null;
                    $assigned_to = isset($data->assigned_to) ? htmlspecialchars(strip_tags($data->assigned_to)) : null;
                    $status = htmlspecialchars(strip_tags($data->status));
                    $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                    $completion_percentage = htmlspecialchars(strip_tags($data->completion_percentage));
                    
                    $stmt->bindParam(':id', $id);
                    $stmt->bindParam(':product_name', $product_name);
                    $stmt->bindParam(':current_stage', $current_stage);
                    $stmt->bindParam(':start_date', $start_date);
                    $stmt->bindParam(':end_date', $end_date);
                    $stmt->bindParam(':assigned_to', $assigned_to);
                    $stmt->bindParam(':status', $status);
                    $stmt->bindParam(':notes', $notes);
                    $stmt->bindParam(':completion_percentage', $completion_percentage);
                    
                    $stmt->execute();
                    
                    // Update logs if provided
                    if(isset($data->used_logs)) {
                        // Remove existing log associations
                        $query = "DELETE FROM production_logs WHERE production_id = :production_id";
                        $stmt = $conn->prepare($query);
                        $stmt->bindParam(':production_id', $id);
                        $stmt->execute();
                        
                        // Add new log associations
                        foreach($data->used_logs as $log_id) {
                            $query = "INSERT INTO production_logs (production_id, log_id) VALUES (:production_id, :log_id)";
                            $stmt = $conn->prepare($query);
                            $stmt->bindParam(':production_id', $id);
                            $stmt->bindParam(':log_id', $log_id);
                            $stmt->execute();
                        }
                    }
                    
                    // Commit transaction
                    $conn->commit();
                    
                    // Fetch the updated production
                    $query = "SELECT * FROM productions WHERE id = :id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':id', $id);
                    $stmt->execute();
                    $production = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    // Add logs to response
                    $production['used_logs'] = $data->used_logs ?? [];
                    
                    http_response_code(200);
                    echo json_encode($production);
                } catch(Exception $e) {
                    // Rollback transaction on error
                    $conn->rollBack();
                    http_response_code(500);
                    echo json_encode(["message" => "Unable to update production: " . $e->getMessage()]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["message" => "Unable to update production. Data is incomplete"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No production ID provided"]);
        }
        break;
        
    case 'DELETE':
        // Delete a production
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            // Start transaction
            $conn->beginTransaction();
            
            try {
                // Delete production logs associations
                $query = "DELETE FROM production_logs WHERE production_id = :production_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':production_id', $id);
                $stmt->execute();
                
                // Delete production
                $query = "DELETE FROM productions WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                
                // Commit transaction
                $conn->commit();
                
                http_response_code(200);
                echo json_encode(["message" => "Production deleted successfully"]);
            } catch(Exception $e) {
                // Rollback transaction on error
                $conn->rollBack();
                http_response_code(500);
                echo json_encode(["message" => "Unable to delete production: " . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No production ID provided"]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not allowed"]);
        break;
}
?> 