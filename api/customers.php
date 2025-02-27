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
        // Get all customers or a specific customer
        if(isset($_GET['id'])) {
            // Get specific customer by ID
            $id = $_GET['id'];
            
            // Get customer details
            $query = "SELECT c.*, 
                      COUNT(o.id) as total_orders,
                      SUM(o.total_amount) as total_spent
                      FROM customers c
                      LEFT JOIN orders o ON c.id = o.customer_id
                      WHERE c.id = :id
                      GROUP BY c.id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $customer = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if($customer) {
                echo json_encode($customer);
            } else {
                http_response_code(404);
                echo json_encode(["message" => "Customer not found"]);
            }
        } else {
            // Get all customers with order counts and total spent
            $query = "SELECT c.*, 
                      COUNT(o.id) as total_orders,
                      SUM(o.total_amount) as total_spent
                      FROM customers c
                      LEFT JOIN orders o ON c.id = o.customer_id
                      GROUP BY c.id
                      ORDER BY c.name ASC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $customers = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode($customers);
        }
        break;
        
    case 'POST':
        // Add a new customer
        $data = json_decode(file_get_contents("php://input"));
        
        if(
            !empty($data->name) &&
            !empty($data->email)
        ) {
            $query = "INSERT INTO customers
                      (name, email, phone_number, address, company, notes, created_date)
                      VALUES
                      (:name, :email, :phone_number, :address, :company, :notes, CURDATE())";
            
            $stmt = $conn->prepare($query);
            
            // Sanitize and bind parameters
            $name = htmlspecialchars(strip_tags($data->name));
            $email = htmlspecialchars(strip_tags($data->email));
            $phone_number = isset($data->phone_number) ? htmlspecialchars(strip_tags($data->phone_number)) : null;
            $address = isset($data->address) ? htmlspecialchars(strip_tags($data->address)) : null;
            $company = isset($data->company) ? htmlspecialchars(strip_tags($data->company)) : null;
            $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
            
            $stmt->bindParam(':name', $name);
            $stmt->bindParam(':email', $email);
            $stmt->bindParam(':phone_number', $phone_number);
            $stmt->bindParam(':address', $address);
            $stmt->bindParam(':company', $company);
            $stmt->bindParam(':notes', $notes);
            
            if($stmt->execute()) {
                $lastId = $conn->lastInsertId();
                
                // Fetch the newly created customer
                $query = "SELECT * FROM customers WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $lastId);
                $stmt->execute();
                $customer = $stmt->fetch(PDO::FETCH_ASSOC);
                
                // Add default values for order stats
                $customer['total_orders'] = 0;
                $customer['total_spent'] = null;
                
                http_response_code(201);
                echo json_encode($customer);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to create customer"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Unable to create customer. Data is incomplete"]);
        }
        break;
        
    case 'PUT':
        // Update an existing customer
        $data = json_decode(file_get_contents("php://input"));
        
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            if(
                !empty($data->name) &&
                !empty($data->email)
            ) {
                $query = "UPDATE customers
                          SET name = :name,
                              email = :email,
                              phone_number = :phone_number,
                              address = :address,
                              company = :company,
                              notes = :notes
                          WHERE id = :id";
                
                $stmt = $conn->prepare($query);
                
                // Sanitize and bind parameters
                $name = htmlspecialchars(strip_tags($data->name));
                $email = htmlspecialchars(strip_tags($data->email));
                $phone_number = isset($data->phone_number) ? htmlspecialchars(strip_tags($data->phone_number)) : null;
                $address = isset($data->address) ? htmlspecialchars(strip_tags($data->address)) : null;
                $company = isset($data->company) ? htmlspecialchars(strip_tags($data->company)) : null;
                $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                
                $stmt->bindParam(':id', $id);
                $stmt->bindParam(':name', $name);
                $stmt->bindParam(':email', $email);
                $stmt->bindParam(':phone_number', $phone_number);
                $stmt->bindParam(':address', $address);
                $stmt->bindParam(':company', $company);
                $stmt->bindParam(':notes', $notes);
                
                if($stmt->execute()) {
                    // Fetch the updated customer with order stats
                    $query = "SELECT c.*, 
                              COUNT(o.id) as total_orders,
                              SUM(o.total_amount) as total_spent
                              FROM customers c
                              LEFT JOIN orders o ON c.id = o.customer_id
                              WHERE c.id = :id
                              GROUP BY c.id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':id', $id);
                    $stmt->execute();
                    $customer = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    http_response_code(200);
                    echo json_encode($customer);
                } else {
                    http_response_code(500);
                    echo json_encode(["message" => "Unable to update customer"]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["message" => "Unable to update customer. Data is incomplete"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No customer ID provided"]);
        }
        break;
        
    case 'DELETE':
        // Delete a customer
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            $query = "DELETE FROM customers WHERE id = :id";
            $stmt = $conn->prepare($query);
            $stmt->bindParam(':id', $id);
            
            if($stmt->execute()) {
                http_response_code(200);
                echo json_encode(["message" => "Customer deleted successfully"]);
            } else {
                http_response_code(500);
                echo json_encode(["message" => "Unable to delete customer"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No customer ID provided"]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not allowed"]);
        break;
}
?> 