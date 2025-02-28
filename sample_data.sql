-- Sample data for NgaraTimber Management System

-- Insert sample logs
INSERT INTO logs (log_number, species, diameter, length, quality, source, status, received_date, notes) VALUES
('LOG001', 'Pine', 30.5, 400, 'A-Grade', 'Arusha Forest', 'in_stock', '2023-05-10', 'Good quality pine log'),
('LOG002', 'Oak', 45.2, 350, 'B-Grade', 'Meru Plantation', 'in_stock', '2023-05-12', 'Some minor defects'),
('LOG003', 'Mahogany', 50.0, 420, 'A-Grade', 'Kilimanjaro Region', 'in_production', '2023-05-15', 'Premium quality'),
('LOG004', 'Teak', 35.8, 380, 'A-Grade', 'Usa River', 'in_stock', '2023-05-18', 'Excellent condition'),
('LOG005', 'Cedar', 40.2, 410, 'B-Grade', 'Tengeru', 'sold', '2023-05-20', 'Sold to Karibu Furniture');

-- Insert sample inventory items
INSERT INTO inventory (name, type, quantity, unit, price, location, status, description) VALUES
('Pine Planks', 'finished_product', 150, 'piece', 2500, 'Warehouse A', 'in_stock', 'Processed pine planks ready for sale'),
('Oak Boards', 'finished_product', 85, 'piece', 4500, 'Warehouse B', 'in_stock', 'Finished oak boards'),
('Mahogany Veneer', 'finished_product', 200, 'sheet', 3000, 'Warehouse A', 'in_stock', 'Thin mahogany veneer sheets'),
('Raw Teak', 'raw_material', 10, 'log', 25000, 'Yard B', 'low_stock', 'Unprocessed teak logs'),
('Cedar Blocks', 'finished_product', 45, 'piece', 3500, 'Warehouse C', 'in_stock', 'Cedar blocks for furniture');

-- Insert sample production records
INSERT INTO productions (product_name, current_stage, start_date, end_date, status, notes, completion_percentage) VALUES
('Custom Dining Table', 'cutting', '2023-06-01', NULL, 'in_progress', 'Oak dining table for Serengeti Hotel', 25.00),
('Office Desks (5 units)', 'assembly', '2023-05-25', NULL, 'in_progress', 'Batch of 5 office desks for Moshi Tech', 60.00),
('Bedroom Set', 'planning', '2023-06-05', NULL, 'not_started', 'Complete bedroom set for Mr. Kimaro', 0.00),
('Kitchen Cabinets', 'finishing', '2023-05-15', NULL, 'in_progress', 'Custom kitchen cabinets for Mama Anna Restaurant', 85.00),
('Outdoor Benches', 'completed', '2023-05-10', '2023-06-02', 'completed', '10 outdoor benches for Arusha National Park', 100.00);

-- Insert sample customers
INSERT INTO customers (name, email, phone_number, address, company, notes, created_date) VALUES
('Juma Mbasha', 'juma.mbasha@example.com', '+255 755 123 456', '123 Sokoine Road, Arusha', 'Mbasha Constructions', 'Regular customer, prefers mahogany', '2023-01-15'),
('Neema Mollel', 'neema@karibu-furniture.co.tz', '+255 765 234 567', '45 Serengeti Street, Arusha', 'Karibu Furniture', 'Wholesale customer', '2023-02-20'),
('Serengeti Hotel', 'procurement@serengeti-hotel.co.tz', '+255 782 345 678', 'Dodoma Road, Arusha', 'Serengeti Hotel', 'High-end hotel client', '2023-03-10'),
('Emmanuel Kimaro', 'ekimaro@gmail.com', '+255 745 456 789', '78 Moshi Road, Arusha', NULL, 'Referred by Neema', '2023-04-05'),
('Mama Anna Restaurant', 'info@mama-anna.co.tz', '+255 773 567 890', '15 Nyerere Avenue, Arusha', 'Mama Anna Restaurant', 'New client, kitchen renovation', '2023-05-01');

-- Insert sample orders
INSERT INTO orders (customer_id, order_date, status, total_amount, delivery_date, payment_status, notes) VALUES
(1, '2023-05-15', 'delivered', 125000, '2023-05-25', 'paid', 'Delivered on time'),
(2, '2023-05-20', 'processing', 345000, '2023-06-10', 'partial', 'Partial payment received'),
(3, '2023-05-25', 'pending', 780000, '2023-07-05', 'pending', 'Waiting for material availability'),
(4, '2023-06-01', 'processing', 95000, '2023-06-15', 'paid', 'Custom bedroom furniture'),
(5, '2023-06-05', 'pending', 250000, '2023-06-30', 'pending', 'Kitchen cabinets and countertops');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price) VALUES
(1, 1, 'Pine Planks', 30, 2500, 75000),
(1, 3, 'Mahogany Veneer', 20, 2500, 50000),
(2, 2, 'Oak Boards', 50, 4500, 225000),
(2, 5, 'Cedar Blocks', 35, 3500, 122500),
(3, 2, 'Oak Boards', 80, 4500, 360000),
(3, 3, 'Mahogany Veneer', 140, 3000, 420000),
(4, 1, 'Pine Planks', 38, 2500, 95000),
(5, 5, 'Cedar Blocks', 45, 3500, 157500),
(5, 1, 'Pine Planks', 37, 2500, 92500);

-- Insert sample notifications
INSERT INTO notifications (title, message, type, user_id, is_read, created_at) VALUES
('Low Stock Alert', 'Raw Teak is running low on stock. Current quantity: 10 logs', 'stockUpdate', NULL, 0, NOW()),
('Order Completed', 'Order #1 for Juma Mbasha has been delivered and marked as complete', 'orderStatus', NULL, 1, NOW() - INTERVAL 2 DAY),
('Production Update', 'Kitchen Cabinets production is now 85% complete', 'productionUpdate', NULL, 0, NOW() - INTERVAL 1 DAY),
('New Customer', 'Mama Anna Restaurant has been added as a new customer', 'general', NULL, 1, NOW() - INTERVAL 3 DAY),
('Stock Update', 'Pine Planks inventory has been updated from 120 to 150 pieces', 'stockUpdate', NULL, 0, NOW() - INTERVAL 12 HOUR); 