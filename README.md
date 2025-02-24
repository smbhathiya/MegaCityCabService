# Mega City Cabs

Mega City Cabs is a web-based cab management system developed using Java, JSP, Servlets, MySQL, and Tailwind CSS. It facilitates cab booking, payment processing, and ride management for customers and drivers, with a scalable architecture that can support future admin functionalities. The system integrates a responsive front-end with a robust back-end to provide a seamless user experience.

## Features

### User Roles and Functionalities

- **Customers**:
  - **Registration & Login**: Sign up and log in securely to access the system.
  - **Ride Booking**: Book cabs by specifying pickup/drop-off locations, date, and time.
  - **Booking History**: View confirmed, completed, and cancelled bookings.
  - **Payment Management**: Pay for confirmed rides via cash or card (card payment mocked), view payment history.

- **Drivers**:
  - **Registration & Login**: Sign up and log in to manage ride assignments.
  - **Booking Management**: View confirmed bookings, update statuses (completed/cancelled).
  - **Payment Tracking**: Monitor total payments received and pending payments from confirmed rides, confirm payment receipt.

- **Admins** (Future Scope):
  - Manage users (customers and drivers), cars, and system-wide settings.

### Key Functions

- **Authentication**: Secure user authentication with session management.
- **Booking Management**: Create, update, and view bookings with statuses (`pending`, `confirmed`, `completed`, `cancelled`).
- **Payment Processing**: Handle payments (cash and mocked card), update `bookings` and `payments` tables, track payment history.
- **Responsive UI**: Built with Tailwind CSS and Lucide icons for a modern, mobile-friendly interface.
- **Database Integration**: MySQL backend with tables for `users`, `customers`, `drivers`, `cars`, `bookings`, and `payments`.

## Prerequisites

To set up and run Mega City Cabs locally, ensure you have the following installed:

- **Java**: JDK 20 or later
- **IDE**: IntelliJ IDEA (recommended), Eclipse, or any Java-supporting IDE
- **MySQL**: 8.0 or later
- **Tomcat**: 10.0 or later
- **Git**: For cloning the repository
- **Maven**: For dependency management (bundled with IntelliJ or installed separately)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone [https://github.com/your-username/mega-city-cabs.git](https://github.com/smbhathiya/MegaCityCabService.git)
cd MegaCityCabService
```

### 2. Set Up the Database

#### Install MySQL:
- Download MySQL from [mysql.com](https://www.mysql.com/).
- Install and start the MySQL server.

#### Create Database:
```sql
CREATE DATABASE megacitycabs;
```

#### Import Database Schema:
```bash
mysql -u your-username -p megacitycabs < path/to/megacitycabs.sql
```
Replace `your-username` with your MySQL username and enter your password when prompted.

### 3. Configure Database Connection

Open `src/main/java/com/cabservice/megacitycabservice/util/DBUtil.java` and update credentials:

```java
private static final String URL = "jdbc:mysql://localhost:3306/megacitycabs?useSSL=false&serverTimezone=UTC";
private static final String USER = "your-mysql-username"; // e.g., "root"
private static final String PASSWORD = "your-mysql-password"; // e.g., "password123"
```
Save the file.

### 4. Open Project in IntelliJ IDEA

- Launch IntelliJ IDEA.
- Open Project:  
  - Go to **File > Open**, select the `mega-city-cabs` folder, and click **OK**.
- Configure SDK:  
  - **File > Project Structure > Project Settings > Project**.
  - Set **Project SDK** to **JDK 20** (or your installed version).
- Set Up Maven:  
  - IntelliJ should auto-detect `pom.xml`.  
  - If not, right-click `pom.xml` > **Add as Maven Project**.
  - Open the terminal in IntelliJ and run:

```bash
mvn clean install
```

This downloads dependencies and builds the project.

### 5. Set Up Tomcat 10

#### Download Tomcat:
- Get Tomcat 10 from [tomcat.apache.org](https://tomcat.apache.org/).
- Extract it to a directory (e.g., `C:\apache-tomcat-10` on Windows or `/opt/tomcat` on Linux).

#### Configure Tomcat in IntelliJ:
- **Run > Edit Configurations > + (Add New Configuration) > Tomcat Server > Local**.
- Name it `"Tomcat 10"`.
- Under `"Application Server"`, click **Configure**, then select the Tomcat home directory (e.g., `C:\apache-tomcat-10`).
- In the `"Deployment"` tab, click **+ > Artifact**, select `MegaCityCabService:war` (or exploded version), and set the context path to `/MegaCityCabService`.
- Click **Apply > OK**.

### 6. Run the Application

- Click the green **"Run"** button or **Run > Run 'Tomcat 10'**.
- Open a browser and navigate to:

```
http://localhost:8080/MegaCityCabService/
```

The landing page (`index.jsp`) should load, showing login/register options.

## Troubleshooting

### 404 Errors:
- Verify servlet `@WebServlet` mappings match JSP fetch URLs.
- Check Tomcat deployment context path (e.g., `/MegaCityCabService`).

### Database Connection Issues:
- Ensure MySQL is running and credentials in `DBUtil` are correct.
- Test connection:

```bash
mysql -u your-username -p
```

### Build Errors:
- Run:

```bash
mvn clean install
```

- Ensure JDK version matches project settings.

###
