-- Tạo Cơ Sở Dữ Liệu
-- CREATE DATABASE IF NOT EXISTS jolieshop_db;
-- USE jolieshop_db;

-- 1. Bảng `users` (Người Dùng)
-- Lưu trữ thông tin tài khoản người dùng và quản trị viên
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `user_type` ENUM('user', 'admin') NOT NULL DEFAULT 'user', -- Phân quyền user/admin
  `address` VARCHAR(255) NULL,
  `phone_number` VARCHAR(20) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Bảng `categories` (Danh Mục Sản Phẩm)
-- Lưu trữ các danh mục sản phẩm (ví dụ: Váy, Áo, Túi xách)
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE, -- Dùng cho URL thân thiện
  `description` TEXT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Bảng `products` (Sản Phẩm)
-- Lưu trữ thông tin chi tiết về từng sản phẩm
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến bảng categories
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `price` DECIMAL(10, 2) NOT NULL,
  `description` TEXT NULL,
  `image` VARCHAR(255) NULL, -- Đường dẫn đến hình ảnh sản phẩm
  `stock` INT(10) UNSIGNED NOT NULL DEFAULT 0, -- Số lượng tồn kho
  `is_featured` BOOLEAN NOT NULL DEFAULT FALSE, -- Sản phẩm nổi bật
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Bảng `carts` (Giỏ Hàng)
-- Lưu trữ các sản phẩm hiện có trong giỏ hàng của từng người dùng
DROP TABLE IF EXISTS `carts`;
CREATE TABLE `carts` (
  `user_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến người dùng (user_id là PK ở đây)
  `product_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến sản phẩm
  `quantity` INT(10) UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `product_id`), -- Khóa chính kép
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Bảng `orders` (Đơn Hàng)
-- Lưu trữ thông tin chung của một đơn hàng
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến người đặt hàng
  `total_amount` DECIMAL(10, 2) NOT NULL, -- Tổng số tiền của đơn hàng
  `shipping_address` VARCHAR(255) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL, -- Ví dụ: COD, Chuyển khoản
  `order_status` ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  `placed_on` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Bảng `order_details` (Chi Tiết Đơn Hàng)
-- Lưu trữ thông tin từng sản phẩm trong một đơn hàng cụ thể
DROP TABLE IF EXISTS `order_details`;
CREATE TABLE `order_details` (
  `order_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến đơn hàng
  `product_id` INT(10) UNSIGNED NOT NULL, -- Khóa ngoại trỏ đến sản phẩm
  `quantity` INT(10) UNSIGNED NOT NULL,
  `price_at_order` DECIMAL(10, 2) NOT NULL, -- Giá sản phẩm tại thời điểm đặt hàng
  PRIMARY KEY (`order_id`, `product_id`), -- Khóa chính kép
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm Indexes để tối ưu hiệu suất truy vấn
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);

-- Ghi chú: Cấu trúc này không bao gồm bảng 'message' và 'wishlist' từ các file cũ vì chúng thường được coi là dữ liệu không quan trọng bằng các bảng giao dịch trên, nhưng nếu bạn cần chúng, vui lòng thông báo!