# Overview
This repository contains content and resources used to develop the material for the CNCF Webinar on the Drasi Project (https://github.com/drasi-project), which was recently accepted into the CNCF Sandbox.

The goal of the webinar is to introduce Drasi and to demonstrate its unique approach and features for building "change-driven solutions" as defined in the article [Optimizing Change-Driven Architectures with Drasi](https://techcommunity.microsoft.com/blog/linuxandopensourceblog/optimizing-change-driven-architectures-with-drasi/4404675).

# The Presentation
The webinar will follow the structure outlined below:
- Explain the business problem being solved (i.e. reacting quickly to changes in data) and define the category of change-driven solutions, distinguishing them from generic event processing systems.
- Demonstrate a working change-driven solution that was built using Drasi. The solution will be a simplified ordering and inventory management scenario. It will demonstrate both reacting to data changes as well as reacting in the absence of change.
- Describe how developers would typically build change driven solutions without Drasi: polling databases, processing change logs, stream processing, and analytics platforms. EMphasize the complexity involved in these approaches.
- Explain how Drasi removes much of this complexity and discuss the three main architectural components of Drasi: Sources, Continuous Queries, and Reactions.
- Invite the audience to try Drasi, provide resources for them to get started, and encourage them to contribute to the project.

# The Demo

A working example of a change-driven solution built using Drasi.

## Scenario

A simplified ordering and inventory management system.

## Business Problem

### Use Case 1 (reacting to change)
When the available inventory of a product is less than or equal to its reorder level, the system should place a new order with the product's supplier. The reorder level is configured as a property of a given product. The available inventory is determined by the quantity of the product in stock and on order from its supplier minus the quantity of the product that has been ordered by customers but not yet delivered.

### Use Case 2 (reacting to the absence of)
When an order is placed with a supplier, if the supplier has not provided a delivery date within 15 minutes, the system will flag the order for manual review.

# Databases
Database 1: Retail Operations
Technology: PostgreSQL
Tables:
- customer_order: Contains order details including order ID, customer ID, order date.
- customer_order_item: Contains items in each order, including order ID, product ID, quantity, and price.

Database 2: Inventory Management
Technology: PostgreSQL
Tables:
- supplier_order: Contains order details with suppliers including order ID, supplier ID, order date, and delivery date.
- supplier_order_item: Contains items in each supplier order, including order ID, product ID, quantity, and price.
- product: Contains product details including product ID, supplier ID, name, description, price, and reorder level.

