-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Aug 22, 2022 at 03:07 PM
-- Server version: 5.7.36
-- PHP Version: 8.0.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foodie_admin_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `permission` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `routes` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `permissions` (`id`, `role_id`, `permission`, `routes`, `created_at`, `updated_at`) VALUES
(1, 1, 'god-eye', 'map', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(2, 1, 'roles', 'role.index', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(3, 1, 'roles', 'role.save', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(4, 1, 'roles', 'role.store', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(5, 1, 'roles', 'role.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(6, 1, 'roles', 'role.update', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(7, 1, 'roles', 'role.delete', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(8, 1, 'admins', 'admin.users', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(9, 1, 'admins', 'admin.users.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(10, 1, 'admins', 'admin.users.store', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(11, 1, 'admins', 'admin.users.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(12, 1, 'admins', 'admin.users.update', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(13, 1, 'admins', 'admin.users.delete', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(14, 1, 'users', 'users', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(15, 1, 'users', 'users.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(16, 1, 'users', 'users.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(17, 1, 'users', 'users.view', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(18, 1, 'vendors', 'vendors', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(19, 1, 'restaurants', 'restaurants', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(20, 1, 'restaurants', 'restaurants.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(21, 1, 'restaurants', 'restaurants.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(22, 1, 'restaurants', 'restaurants.view', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(23, 1, 'drivers', 'drivers', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(24, 1, 'drivers', 'drivers.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(25, 1, 'drivers', 'drivers.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(26, 1, 'drivers', 'drivers.view', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(27, 1, 'reports', 'report.index', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(28, 1, 'category', 'categories', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(29, 1, 'category', 'categories.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(30, 1, 'category', 'categories.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(31, 1, 'foods', 'foods', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(32, 1, 'foods', 'foods.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(33, 1, 'foods', 'foods.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(34, 1, 'item-attribute', 'attributes', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(35, 1, 'item-attribute', 'attributes.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(36, 1, 'item-attribute', 'attributes.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(37, 1, 'review-attribute', 'reviewattributes', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(38, 1, 'review-attribute', 'reviewattributes.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(39, 1, 'review-attribute', 'reviewattributes.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(40, 1, 'orders', 'orders', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(41, 1, 'orders', 'vendors.orderprint', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(42, 1, 'orders', 'orders.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(43, 1, 'dinein-orders', 'restaurants.booktable', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(44, 1, 'dinein-orders', 'booktable.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(45, 1, 'gift-cards', 'gift-card.index', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(46, 1, 'gift-cards', 'gift-card.save', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(47, 1, 'gift-cards', 'gift-card.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(48, 1, 'coupons', 'coupons', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(49, 1, 'coupons', 'coupons.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(50, 1, 'coupons', 'coupons.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(51, 1, 'general-notifications', 'notification', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(52, 1, 'general-notifications', 'notification.send', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(53, 1, 'dynamic-notifications', 'dynamic-notification.index', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(54, 1, 'dynamic-notifications', 'dynamic-notification.save', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(55, 1, 'payments', 'payments', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(56, 1, 'restaurant-payouts', 'restaurantsPayouts', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(57, 1, 'restaurant-payouts', 'restaurantsPayouts.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(58, 1, 'driver-payments', 'driver.driverpayments', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(59, 1, 'driver-payouts', 'driversPayouts', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(60, 1, 'driver-payouts', 'driversPayouts.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(61, 1, 'wallet-transaction', 'walletstransaction', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(62, 1, 'payout-request', 'payoutRequests.drivers', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(63, 1, 'payout-request', 'payoutRequests.restaurants', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(64, 1, 'banners', 'setting.banners', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(65, 1, 'banners', 'setting.banners.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(66, 1, 'banners', 'setting.banners.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(67, 1, 'cms', 'cms', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(68, 1, 'cms', 'cms.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(69, 1, 'cms', 'cms.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(70, 1, 'email-template', 'email-templates.index', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(71, 1, 'email-template', 'email-templates.save', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(72, 1, 'email-template', 'email-templates.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(73, 1, 'global-setting', 'settings.app.globals', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(74, 1, 'currency', 'currencies', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(75, 1, 'currency', 'currencies.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(76, 1, 'currency', 'currencies.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(77, 1, 'payment-method', 'payment-method', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(78, 1, 'admin-commission', 'settings.app.adminCommission', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(79, 1, 'radius', 'settings.app.radiusConfiguration', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(80, 1, 'dinein', 'settings.app.bookTable', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(81, 1, 'tax', 'tax', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(82, 1, 'tax', 'tax.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(83, 1, 'tax', 'tax.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(84, 1, 'delivery-charge', 'settings.app.deliveryCharge', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(85, 1, 'language', 'settings.app.languages', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(86, 1, 'language', 'settings.app.languages.create', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(87, 1, 'language', 'settings.app.languages.edit', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(88, 1, 'special-offer', 'setting.specialOffer', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(89, 1, 'terms', 'termsAndConditions', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(90, 1, 'privacy', 'privacyPolicy', '2023-11-29 14:27:36', '2023-11-29 14:27:36'),
(91, 1, 'home-page', 'homepageTemplate', '2023-11-29 14:49:12', '2023-11-29 14:49:12'),
(92, 1, 'footer', 'footerTemplate', '2023-11-29 14:49:12', '2023-11-29 14:49:12');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE IF NOT EXISTS `role` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `role` (`id`, `role_name`, `created_at`, `updated_at`) VALUES
(1, 'Super Administrator', '2023-11-27 05:10:43', '2023-11-27 06:36:20');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int(15) NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role_id`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'admin@foodie.com', NULL, '$2y$10$4D/Oi3x7gxPwZ/zxCKtgCOlPNujUnUER0vkMjQ0moL7l3cAJwTIJa', 1, 'xmMQOp8aT80phlL2714CfAxZxeNw7SNcHzGCWIflETi8sfsygU4VZuh5xZTg', '2022-02-26 12:22:29', '2023-11-29 10:45:57');

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
