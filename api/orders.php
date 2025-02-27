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
        // Get all orders or a specific order
        if(isset($_GET['id'])) {
            // Get specific order by ID
            $id = $_GET['id'];
            
            // Start transaction
            $conn->beginTransaction();
            
            try {
                // Get order details
                $query = "SELECT * FROM orders WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                $order = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if($order) {
                    // Get order items
                    $query = "SELECT * FROM order_items WHERE order_id = :order_id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':order_id', $id);
                    $stmt->execute();
                    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    // Add items to order data
                    $order['items'] = $items;
                    
                    // Commit transaction
                    $conn->commit();
                    
                    echo json_encode($order);
                } else {
                    // Commit transaction
                    $conn->commit();
                    
                    http_response_code(404);
                    echo json_encode(["message" => "Order not found"]);
                }
            } catch(Exception $e) {
                // Rollback transaction on error
                $conn->rollBack();
                http_response_code(500);
                echo json_encode(["message" => "Error: " . $e->getMessage()]);
            }
        } else {
            // Get all orders with customer info
            $query = "SELECT o.*, c.name as customer_name 
                      FROM orders o
                      JOIN customers c ON o.customer_id = c.id
                      ORDER BY o.order_date DESC";
            $stmt = $conn->prepare($query);
            $stmt->execute();
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode($orders);
        }
        break;
        
    case 'POST':
        // Add a new order
        $data = json_decode(file_get_contents("php://input"));
        
        if(
            !empty($data->customer_id) &&
            !empty($data->order_date) &&
            !empty($data->status) &&
            !empty($data->total_amount) &&
            !empty($data->items) &&
            is_array($data->items)
        ) {
            // Start transaction
            $conn->beginTransaction();
            
            try {
                $query = "INSERT INTO orders
                          (customer_id, order_date, status, total_amount, delivery_date, payment_status, notes)
                          VALUES
                          (:customer_id, :order_date, :status, :total_amount, :delivery_date, :payment_status, :notes)";
                
                $stmt = $conn->prepare($query);
                
                // Sanitize and bind parameters
                $customer_id = htmlspecialchars(strip_tags($data->customer_id));
                $order_date = htmlspecialchars(strip_tags($data->order_date));
                $status = htmlspecialchars(strip_tags($data->status));
                $total_amount = htmlspecialchars(strip_tags($data->total_amount));
                $delivery_date = isset($data->delivery_date) ? htmlspecialchars(strip_tags($data->delivery_date)) : null;
                $payment_status = isset($data->payment_status) ? htmlspecialchars(strip_tags($data->payment_status)) : 'pending';
                $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                
                $stmt->bindParam(':customer_id', $customer_id);
                $stmt->bindParam(':order_date', $order_date);
                $stmt->bindParam(':status', $status);
                $stmt->bindParam(':total_amount', $total_amount);
                $stmt->bindParam(':delivery_date', $delivery_date);
                $stmt->bindParam(':payment_status', $payment_status);
                $stmt->bindParam(':notes', $notes);
                
                $stmt->execute();
                $order_id = $conn->lastInsertId();
                
                // Add order items
                foreach($data->items as $item) {
                    $query = "INSERT INTO order_items
                              (order_id, product_id, product_name, quantity, unit_price, total_price)
                              VALUES
                              (:order_id, :product_id, :product_name, :quantity, :unit_price, :total_price)";
                    
                    $stmt = $conn->prepare($query);
                    
                    // Sanitize and bind parameters
                    $product_id = htmlspecialchars(strip_tags($item->product_id));
                    $product_name = htmlspecialchars(strip_tags($item->product_name));
                    $quantity = htmlspecialchars(strip_tags($item->quantity));
                    $unit_price = htmlspecialchars(strip_tags($item->unit_price));
                    $total_price = htmlspecialchars(strip_tags($item->total_price));
                    
                    $stmt->bindParam(':order_id', $order_id);
                    $stmt->bindParam(':product_id', $product_id);
                    $stmt->bindParam(':product_name', $product_name);
                    $stmt->bindParam(':quantity', $quantity);
                    $stmt->bindParam(':unit_price', $unit_price);
                    $stmt->bindParam(':total_price', $total_price);
                    
                    $stmt->execute();
                    
                    // Update inventory quantity
                    $query = "UPDATE inventory 
                              SET quantity = quantity - :quantity,
                                  status = CASE 
                                      WHEN (quantity - :quantity) <= 0 THEN 'out_of_stock'
                                      WHEN (quantity - :quantity) < 10 THEN 'low_stock'
                                      ELSE status
                                  END
                              WHERE id = :product_id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':quantity', $quantity);
                    $stmt->bindParam(':product_id', $product_id);
                    $stmt->execute();
                }
                
                // Commit transaction
                $conn->commit();
                
                // Fetch the newly created order with items
                $query = "SELECT * FROM orders WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $order_id);
                $stmt->execute();
                $order = $stmt->fetch(PDO::FETCH_ASSOC);
                
                // Get order items
                $query = "SELECT * FROM order_items WHERE order_id = :order_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':order_id', $order_id);
                $stmt->execute();
                $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                // Add items to order data
                $order['items'] = $items;
                
                http_response_code(201);
                echo json_encode($order);
            } catch(Exception $e) {
                // Rollback transaction on error
                $conn->rollBack();
                http_response_code(500);
                echo json_encode(["message" => "Unable to create order: " . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "Unable to create order. Data is incomplete"]);
        }
        break;
        
    case 'PUT':
        // Update an existing order
        $data = json_decode(file_get_contents("php://input"));
        
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            if(
                !empty($data->customer_id) &&
                !empty($data->order_date) &&
                !empty($data->status) &&
                !empty($data->total_amount)
            ) {
                // Start transaction
                $conn->beginTransaction();
                
                try {
                    $query = "UPDATE orders
                              SET customer_id = :customer_id,
                                  order_date = :order_date,
                                  status = :status,
                                  total_amount = :total_amount,
                                  delivery_date = :delivery_date,
                                  payment_status = :payment_status,
                                  notes = :notes
                              WHERE id = :id";
                    
                    $stmt = $conn->prepare($query);
                    
                    // Sanitize and bind parameters
                    $customer_id = htmlspecialchars(strip_tags($data->customer_id));
                    $order_date = htmlspecialchars(strip_tags($data->order_date));
                    $status = htmlspecialchars(strip_tags($data->status));
                    $total_amount = htmlspecialchars(strip_tags($data->total_amount));
                    $delivery_date = isset($data->delivery_date) ? htmlspecialchars(strip_tags($data->delivery_date)) : null;
                    $payment_status = isset($data->payment_status) ? htmlspecialchars(strip_tags($data->payment_status)) : 'pending';
                    $notes = isset($data->notes) ? htmlspecialchars(strip_tags($data->notes)) : null;
                    
                    $stmt->bindParam(':id', $id);
                    $stmt->bindParam(':customer_id', $customer_id);
                    $stmt->bindParam(':order_date', $order_date);
                    $stmt->bindParam(':status', $status);
                    $stmt->bindParam(':total_amount', $total_amount);
                    $stmt->bindParam(':delivery_date', $delivery_date);
                    $stmt->bindParam(':payment_status', $payment_status);
                    $stmt->bindParam(':notes', $notes);
                    
                    $stmt->execute();
                    
                    // Update order items if provided
                    if(isset($data->items) && is_array($data->items)) {
                        // First, get current items to adjust inventory
                        $query = "SELECT * FROM order_items WHERE order_id = :order_id";
                        $stmt = $conn->prepare($query);
                        $stmt->bindParam(':order_id', $id);
                        $stmt->execute();
                        $old_items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                        
                        // Return quantities to inventory
                        foreach($old_items as $item) {
                            $query = "UPDATE inventory 
                                      SET quantity = quantity + :quantity,
                                          status = CASE 
                                              WHEN (quantity + :quantity) > 0 AND status = 'out_of_stock' THEN 'low_stock'
                                              WHEN (quantity + :quantity) >= 10 AND status = 'low_stock' THEN 'in_stock'
                                              ELSE status
                                          END
                                      WHERE id = :product_id";
                            $stmt = $conn->prepare($query);
                            $stmt->bindParam(':quantity', $item['quantity']);
                            $stmt->bindParam(':product_id', $item['product_id']);
                            $stmt->execute();
                        }
                        
                        // Remove existing items
                        $query = "DELETE FROM order_items WHERE order_id = :order_id";
                        $stmt = $conn->prepare($query);
                        $stmt->bindParam(':order_id', $id);
                        $stmt->execute();
                        
                        // Add new items
                        foreach($data->items as $item) {
                            $query = "INSERT INTO order_items
                                      (order_id, product_id, product_name, quantity, unit_price, total_price)
                                      VALUES
                                      (:order_id, :product_id, :product_name, :quantity, :unit_price, :total_price)";
                            
                            $stmt = $conn->prepare($query);
                            
                            // Sanitize and bind parameters
                            $product_id = htmlspecialchars(strip_tags($item->product_id));
                            $product_name = htmlspecialchars(strip_tags($item->product_name));
                            $quantity = htmlspecialchars(strip_tags($item->quantity));
                            $unit_price = htmlspecialchars(strip_tags($item->unit_price));
                            $total_price = htmlspecialchars(strip_tags($item->total_price));
                            
                            $stmt->bindParam(':order_id', $id);
                            $stmt->bindParam(':product_id', $product_id);
                            $stmt->bindParam(':product_name', $product_name);
                            $stmt->bindParam(':quantity', $quantity);
                            $stmt->bindParam(':unit_price', $unit_price);
                            $stmt->bindParam(':total_price', $total_price);
                            
                            $stmt->execute();
                            
                            // Update inventory quantity
                            $query = "UPDATE inventory 
                                      SET quantity = quantity - :quantity,
                                          status = CASE 
                                              WHEN (quantity - :quantity) <= 0 THEN 'out_of_stock'
                                              WHEN (quantity - :quantity) < 10 THEN 'low_stock'
                                              ELSE status
                                          END
                                      WHERE id = :product_id";
                            $stmt = $conn->prepare($query);
                            $stmt->bindParam(':quantity', $quantity);
                            $stmt->bindParam(':product_id', $product_id);
                            $stmt->execute();
                        }
                    }
                    
                    // Commit transaction
                    $conn->commit();
                    
                    // Fetch the updated order with items
                    $query = "SELECT * FROM orders WHERE id = :id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':id', $id);
                    $stmt->execute();
                    $order = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    // Get order items
                    $query = "SELECT * FROM order_items WHERE order_id = :order_id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':order_id', $id);
                    $stmt->execute();
                    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    // Add items to order data
                    $order['items'] = $items;
                    
                    http_response_code(200);
                    echo json_encode($order);
                } catch(Exception $e) {
                    // Rollback transaction on error
                    $conn->rollBack();
                    http_response_code(500);
                    echo json_encode(["message" => "Unable to update order: " . $e->getMessage()]);
                }
            } else {
                http_response_code(400);
                echo json_encode(["message" => "Unable to update order. Data is incomplete"]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No order ID provided"]);
        }
        break;
        
    case 'DELETE':
        // Delete an order
        if(isset($_GET['id'])) {
            $id = $_GET['id'];
            
            // Start transaction
            $conn->beginTransaction();
            
            try {
                // Get order items to adjust inventory
                $query = "SELECT * FROM order_items WHERE order_id = :order_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':order_id', $id);
                $stmt->execute();
                $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                // Return quantities to inventory
                foreach($items as $item) {
                    $query = "UPDATE inventory 
                              SET quantity = quantity + :quantity,
                                  status = CASE 
                                      WHEN (quantity + :quantity) > 0 AND status = 'out_of_stock' THEN 'low_stock'
                                      WHEN (quantity + :quantity) >= 10 AND status = 'low_stock' THEN 'in_stock'
                                      ELSE status
                                  END
                              WHERE id = :product_id";
                    $stmt = $conn->prepare($query);
                    $stmt->bindParam(':quantity', $item['quantity']);
                    $stmt->bindParam(':product_id', $item['product_id']);
                    $stmt->execute();
                }
                
                // Delete order items
                $query = "DELETE FROM order_items WHERE order_id = :order_id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':order_id', $id);
                $stmt->execute();
                
                // Delete order
                $query = "DELETE FROM orders WHERE id = :id";
                $stmt = $conn->prepare($query);
                $stmt->bindParam(':id', $id);
                $stmt->execute();
                
                // Commit transaction
                $conn->commit();
                
                http_response_code(200);
                echo json_encode(["message" => "Order deleted successfully"]);
            } catch(Exception $e) {
                // Rollback transaction on error
                $conn->rollBack();
                http_response_code(500);
                echo json_encode(["message" => "Unable to delete order: " . $e->getMessage()]);
            }
        } else {
            http_response_code(400);
            echo json_encode(["message" => "No order ID provided"]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(["message" => "Method not allowed"]);
        break;
}
?> 