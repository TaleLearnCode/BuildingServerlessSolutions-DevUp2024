[Building Serverless Solutions with Azure and .NET](https://github.com/TaleLearnCode/BuildingServerlessSolutions) \ [dev up 2024](..\README.md) \ [Labs](README.md) \

# Lab 7: Inventory Manager Part 2

## Introduction

We will continue the work done in [Lab 4 - Inventory Manager](04-inventory-manager.md), this time handling updating the inventory manager data when a *Next Core in Transit* event is fired.

## Objective

This lab exercise aims to enable you to create another Azure Function that processes messages from an Azure Service Bus topic subscription and updates the inventory status in an Azure Cosmos DB SQL API database using event souring.

## Prerequisites

- **Azure Subscription**: Access to an active Azure subscription with owner permissions.
- **Basic Knowledge of Azure Functions**: You should have gained familiarity with creating and deploying Azure Functions from completing [Lab 1 (Get Next Core)](01-get-next-core.md).
- **Azure Service Bus**: After completing [Lab 1 (Get Next Core)](01-get-next-core.md) and [Lab 3 (Get Next Core Handler)](03-get-next-core-handler.md), you should have gained a basic understanding of Azure Service Bus and its components.
- **Previous Lab Completion**: The [previous lab exercise](03-get-next-core-handler.md) on creating a mocked API endpoint in Azure API Management has been completed.
- **Development Environment**: You have completed [Lab 0 (Initialize Environment)](00-initialize-environment.md), which sets up your local and remote repository and creates the Azure services used in this lab exercise.

## Azure Services Descriptions

You learned about Azure Functions in [Lab 1 (Get Next Core](01-get-next-core.md)) and the Service Bus Topic trigger in [Lab 3 (Get Next Core Handler)](03-get-next-core-handler.md). In this lab, you will also work with Cosmos DB, which is a fully managed, globally distributed, multi-model database service provided by Microsoft. It is designed to offer high availability, scalability, and low-latency access to data for modern applications. Here are some key aspects:

### Key Features

- **Global Distribution**
  - **Multi-Region Replication**: Cosmos DB can replicate your data across multiple Azure regions, ensuring high availability and low-latency access for users worldwide.
  - **Turnkey Global Distribution**: You can easily add or remove regions to your Cosmos DB account anytime without downtime.
- **Multi-Model Support**
  - **Document**: Supports JSON documents, making it ideal for applications that need to store and query hierarchical data.
  - **Key-Value**: Allows for simple key-value pair storage.
  - **Graph**: Supports graph data models, enabling you to store and query graph data using the Gremlin API.
  - **Column-Family**: Supports wide-column stores, using the Apache Cassandra API.
  - **Table**: Supports table storage, using the same API as the Azure Table Storage service.
- **Performance and Scalability**
  - **Single-Digit Millisecond Latency**: Guarantees low-latency reads and writes.
  - **Elastic Scalability**: Automatically scales throughput and storage based on your application's needs.
  - **Serverless and Provisioned Throughput**: This service offers both serverless and provisioned throughput options, allowing you to choose the best pricing model for your workload.
- **Consistency Models**
  - **Five Consistency Levels**: This service offers five consistency levels (Strong, Bounded Staleness, Session, Consistent Prefix, and Eventual) to balance consistency and performance.
- **Integrated Security**
  - **Enterprise-Grade Security**: This product provides built-in security features, including encryption at rest, network isolation, and compliance with various industry standards.
- **Developer-Friendly**
  - **APIs and SDKs**: Supports multiple APIs (SQL, MongoDB, Cassandra, Gremlin, Table) and SDKs for popular programming languages.
  - **Querying**: Offers rich querying capabilities, including SQL-like queries for JSON data.

### Use Cases

- **IoT Applications**: Collect and process data from IoT devices in real time.
- **E-Commerce**: Manage product catalogs, customer profiles, and order processing with low-latency access.
- **Gaming**: Store and retrieve player data, game state, and leaderboards
- **Social Media**: Handle user profiles, posts, and interactions with high availability and scalability.
- **Real-Time Analytics**: Perform real-time analytics on large volumes of data.

## Steps

### Section 0: Open the Remanufacturing Solution

1. From Visual Studio, open the **Remanufacturing** solution.

### Section 1: Add the Warehouse Message Handler Azure Function App

1. Add a class to the *Functions* folder of the `InventoryManager.Functions` project named **NextCoreInTransitHandler.cs** and replace the default content with:

   ```c#
   using Microsoft.Azure.Functions.Worker;
   using Microsoft.Extensions.Logging;
   using Remanufacturing.InventoryManager.Entities;
   using Remanufacturing.InventoryManager.Extensions;
   
   namespace Remanufacturing.InventoryManager.Functions;
   
   public class NextCoreInTransitHandler(ILogger<OrderNextCoreHandler> logger)
   {
   
   	private readonly ILogger<OrderNextCoreHandler> _logger = logger;
   
   	[Function(nameof(NextCoreInTransitHandler))]
   	[CosmosDBOutput(
   		databaseName: "%EventSourceDatabaseName%",
   		containerName: "%EventSourceContainerName%",
   		PartitionKey = "%EventSourcePartitionKey%",
   		Connection = "CosmosDBConnectionString",
   		CreateIfNotExists = false)]
   	public async Task<InventoryEventEntity?> RunAsync(
   		[ServiceBusTrigger("%NextCoreInTransitTopicName%", "%NextCoreInTransitSubscriptionName%", Connection = "ServiceBusConnectionString")] Azure.Messaging.ServiceBus.ServiceBusReceivedMessage message,
   		ServiceBusMessageActions messageActions)
   	{
   		_logger.LogInformation("Message ID: {id}", message.MessageId);
   		_logger.LogInformation("Message Body: {body}", message.Body);
   		_logger.LogInformation("Message Content-Type: {contentType}", message.ContentType);
   
   		InventoryEventEntity? inventoryEventEntity = message.ToInventoryEventEntity(InventoryEventTypes.NextCoreInTransit);
   
   		// Complete the message
   		await messageActions.CompleteMessageAsync(message);
   
   		// Save the message to the Cosmos DB
   		return inventoryEventEntity;
   
   	}
   
   }
   ```

2. Hit the **Ctrl** + **Shift** + **B** key combination to build the solution. Fix any errors.

### Section 3: Prepare for Local Testing

1. Get the name of the **Next Core in Transit** topic by:

   1. From the [Azure Portal](htttps://portal.azure.com), search for `sbns-CoolRevive` and select the Service Bus Namespace created during [Lab 0](00-initialize-environment.md).
   2. Click on **Entities** > **Topics**.
   3. Make note of the full name of the **sbt-coolrevive-nextcoreintransit** service bus topic.

2. Get the name of the **Inventory Management** subscription by:

   1. Click on the **sbt-coolrevive-nextcoreintransit** service bus topic.
   2. In the **Subscriptions** listing, make note of the full name of the **sbts-CoolRevive-NCIT-NotifyMgr** subscription.

3. Add the environment secrets to the Azure Function project by:

   1. Open the local.settings.json file
   2. Add a **NextCoreInTransitTopicName** key with the full name of the **sbt-coolrevive-nextcoreintransit** Service Bus topic.
   3. Add a **NextCoreInTransitSubscriptionName** key with the full name of the **ssbts-CoolRevive-NCIT-NotifyMgr** Service Bus topic subscription.

   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "UseDevelopmentStorage=true",
       "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
       "ServiceBusConnectionString": "ServiceBusConnectionString",
       "OrderNextCoreTopicName": "OrderNextCoreTopicName",
       "OrderNextCoreSubscriptionName": "OrderNextCoreSubscriptionName",
       "CosmosDBConnectionString": "CosmosDBConnectionString",
       "EventSourceDatabaseName": "inventory-manager",
       "EventSourceContainerName": "inventory-manager-events",
       "EventSourcePartitionKey": "/finishedProductId",
       "NextCoreInTransitTopicName": "NextCoreInTransitTopicName",
       "NextCoreInTransitSubscriptionName": "NextCoreInTransitSubscriptionName"
     }
   }
   ```

### Section 4: Test the Azure Function locally

1. Press **F5** to start the Azure Function apps locally.

2. Copy the **GetNextCore** endpoint.

3. Open Postman and enter the **GetNextCore** in the **Enter URL or paste text** field.

4. Change the HTTP method to **POST**.

5. Go the **Body** tab.

6. Select **raw**.

7. Paste the following into the request body field:

   ```json
   {
       "MessageId": "message-123",
       "MessageType": "GetNextCore",
       "PodId": "Pod123"
   }
   ```

   

8. Click the **Send** button. You should receive a **201 Created** response with a response body similar to:

   ```json
   {
       "type": "https://httpstatuses.com/201",
       "title": "Request for next core id sent.",
       "status": 201,
       "detail": "The request for the next core id has been sent to the Production Schedule.",
       "instance": "0HN547NP89O2R:00000001",
       "extensions": {
           "PodId": "Pod123"
       }
   }
   ```

   > At this point, you should see The **GetNextCoreForPod123Handler** Azure Function fire, and then shortly afterward, the **OrderNextCoreHandler** Azure Function will fire.

9. In the [Azure Portal](https://portal.azure.com), search for `cosno-coolrevive-invmgr` and select the Cosmos DB account created in [Lab 0 (Initialize environment)](00-initialize-environment.md).

10. From the left-hand menu, click the **Data Explorer** option.

11. Click the **Service Bus Explorer** menu item.

12. Click on the **inventory-manager-events** container and then click on **Items**.

13. Verify that you see the record that should have just been saved to the container. The record should be similar to this:

    ```json
    {
        "id": "656cea160fe64662b6f770655ce1f5aa",
        "eventType": "OrderNextCore",
        "finishedProductId": "FinishedProduct123",
        "podId": "Pod123",
        "coreId": "Core123",
        "eventTimestamp": "8/11/2024 12:13:15 AM",
        "_rid": "ITpEAICvpMIqAAAAAAAAAA==",
        "_self": "dbs/ITpEAA==/colls/ITpEAICvpMI=/docs/ITpEAICvpMIqAAAAAAAAAA==/",
        "_etag": "\"8f006fbb-0000-0200-0000-66b802190000\"",
        "_attachments": "attachments/",
        "_ts": 1723335193
    }
    ```
    
    

## Conclusion

In this lab exercise, you successfully built an Azure Function triggered by an Azure Service Bus subscription to update the inventory status in an Azure Cosmos DB SQL API database using event sourcing. By completing this exercise, you have:

- Learned how to create and configure an Azure Function with a Service Bus topic trigger.
- Gained an understanding of event sourcing and its application in updating inventory status.
- Implemented logic to process messages and update the inventory status in Azure Cosmos DB.
- Tested the integration between Azure Service Bus, Azure Functions, and Azure Cosmos DB.

These skills are crucial for building robust, scalable, and event-driven applications. You can now apply these techniques to other projects, ensuring that your applications can efficiently handle complex workflows and state management.

## Next Steps

In the next lab exercise, you will create the Warehouse and Conveyance processing. These are two systems outside the Remanufacturing system but are crucial to the Order Next Core process. So, for this workshop, we will create simulations of their functionality.