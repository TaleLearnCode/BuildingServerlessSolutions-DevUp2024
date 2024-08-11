[Building Serverless Solutions with Azure and .NET](https://github.com/TaleLearnCode/BuildingServerlessSolutions) \ [dev up 2024](..\README.md) \ [Labs](README.md) \

# Lab 6: Warehouse and Conveyance

## Introduction

The warehouse and conveyance systems are outside the Remanufacturing domain boundary and, as such, are not developed as part of the Remanufacturing system. However, for the purposes of this tab, we will build simple representations of these systems so that they can contribute to the Order Next Core workflow.

## Objective

This lab exercise aims to enable you to create three different Azure Functions responding to different trigger types: Azure Service Bus topics, Azure Storage queue messages, and Azure Storage.

- Understand how to configure an Azure Function with a Service Bus trigger.

- Understand how to configure an Azure Function with a Queue trigger.
- Understand how to configure an Azure Function with a Blob trigger.
- Implement logic to send an order next core request to the warehouse.
- Implement logic to send a delivery request to the conveyance team.
- Implement logic to call an API Management operation, which in turn sends messages to an Azure Service Bus topic.

## Prerequisites

- **Azure Subscription**: Access to an active Azure subscription with owner permissions.
- **Basic Knowledge of Azure Functions**: You should have gained familiarity with creating and deploying Azure Functions from completing [Lab 1 (Get Next Core)](01-get-next-core.md).
- **Azure Service Bus**: After completing [Lab 1 (Get Next Core)](01-get-next-core.md) and [Lab 3 (Get Next Core Handler)](03-get-next-core-handler.md), you should have gained a basic understanding of Azure Service Bus and its components.
- **Previous Lab Completion**: The [previous lab exercise](03-get-next-core-handler.md) on creating a mocked API endpoint in Azure API Management has been completed.
- **Development Environment**: You have completed [Lab 0 (Initialize Environment)](00-initialize-environment.md), which sets up your local and remote repository and creates the Azure services used in this lab exercise.

- ## Azure Services Descriptions

  You have already learned about Azure Service Bus, Azure Functions, and API Management. We will also work with Azure Storage queues and blobs.

  ### Azure Storage Queue

  Azure Storage Queue is a service provided by Microsoft Azure that allows you to store large numbers of messages that can be accessed from anywhere in the world via authentication calls using HTTP or HTTPS. It is designed for scenarios where you must decouple different parts of your application and ensure reliable communication between them. Each message in the queue can be up to 64 KB in size, and a queue can contain millions of messages, making it highly scalable. Azure Storage Queue is often used for task scheduling, load leveling, and asynchronous processing.

  #### Key Features

  - **Scalability**: Capable of handling millions of messages, ensuring it can grow with your application's needs.
  - **Durability**:  Messages are stored redundantly to ensure high availability and reliability.
  - **Accessibility** Messages can be accessed from anywhere via authenticated HTTP or HTTPS calls.
  - **Decoupling**: This helps decouple different parts of your application, allowing them to communicate asynchronously.
  - **Batching**: Supports batch operations, enabling you to enqueue, dequeue, and delete messages in batches for efficiency.
  - **Integration**: Easily integrates with other Azure services, such as Azure Functions, Logic Apps, and more, for seamless workflows.

  These features make Azure Storage Queue a versatile and reliable choice for managing asynchronous communication in cloud-based applications.

  #### Use Cases

  Azure Storage Queue is versatile and can be used to improve application performance and reliability in various scenarios. Here are some common use cases:

  - **Task Scheduling**: Queue messages can represent tasks that need to be processed, allowing you to schedule and manage background jobs efficiently.
  - **Load Leveling**: Helps balance the load by queuing requests during peak times and processing them when the system is less busy, ensuring smooth performance.
  - **Asynchronous Processing**: Decouples different parts of an application, enabling components to communicate without waiting for each other, which improves responsiveness.
  - **Order Processing**: Manages order processing workflows by queueing orders and processing them sequentially or in batches.
  - **Log Aggregation**: Collects and queues log messages from various sources for centralized processing and analysis.
  - **Event Sourcing**: Stores events in queues to be processed later, ensuring that all events are captured and handled in order.
  - **Workflow Orchestration**: Integrates with Azure Functions and Logic Apps to create complex workflows that handle various tasks and processes.

  ### Azure Blob Storage

  Azure Blob Storage is a service provided by Microsoft Azure that allows you to store and manage large amounts of unstructured data, such as text or binary data. It is designed for various storage scenarios, including servicing images or documents directly to a browser, storing files for distributed access, streaming video and audio, writing to log files, and storing data for backup and restore, disaster recovery, and archiving.

  #### Key Features

  - **Scalability**: Capable of storing petabytes of data.
  - **Durability**: Data is replicated to ensure high availability and reliability.
  - **Accessibility**: Data can be accessed from anywhere via HTTP or HTTPS.
  - **Security**: Supports encryption and fine-grained access control.
  - **Integration**: Easily integrates with other Azure services and tools.

  Azure Blob Storage is an essential service for applications that require scalable, durable, and secure storage for large amounts of unstructured data.

  #### Use Cases

  Azure Blob Storage is highly versatile and can be used in various scenarios. Here are some common uses cases:

  - **Backup and Restore**: Store backups of databases, files, and other critical data to ensure data recovery in case of loss or corruption.
  - **Disaster Recovery**: Keeps copies of essential data in different geographic locations to ensure availability in case of a regional failure.
  - **Content Delivery**: Serve images, videos, documents, and other static content directly to users via a content delivery network (CDN) for faster access.
  - **Big Data Analytics**: Store large datasets for analysis using Azure's big data and machine learning services.
  - **Data Archiving**: Archive infrequently accessed data in a cost-effective manager while ensuring it remains accessible when needed.
  - **Media Storage**: Store and stream media files such as videos and audio for applications like video-on-demand services.
  - **Log Storage**: Collect and store log files from various sources for centralized analysis and monitoring.
  - **File Sharing**: Enable file sharing and collaborations by storing documents and files that multiple users can access.
  - **Static Website Hosting**: Host static websites directly from Blob storage, providing a simple and scalable solution for web content.

  These use cases demonstrate the flexibility and power of Azure Blob Storage in handling various storage needs.


## Steps

### Section 0: Open the Remanufacturing Solution

1. From Visual Studio, open the **Remanufacturing** solution.

### Section 1: Create the Warehouse Message Handler Azure Function

1. Right-click the **Warehouse Message Handler** solution folder and select **Add** > **New Project...**

2. Search for and select **Azure Functions,** and then click the **Next** button.

3. In the **Configure your new project** dialog, provide the following values and then click the **Next** button.

   | Field        | Value                                   |
   | ------------ | --------------------------------------- |
   | Project name | WarehouseMessageHandler.Functions       |
   | Location     | $TargetPath\src\WarehouseMessageHandler |

4. On the **Additional information** dialog, specify the following values:

   | Field                                                        | Value                                 |
   | ------------------------------------------------------------ | ------------------------------------- |
   | Functions worker                                             | .NET 8.0 Isolated (Long Term Support) |
   | Function                                                     | Service Bus Topic trigger             |
   | Use Azureite for runtime storage account (AzureWebJobsStorage) | Checked                               |
   | Enable container support                                     | Unchecked                             |
   | Connection string setting name                               | ServiceBusConnectionString            |
   | Topic name                                                   | %OrderNextCoreTopicName%              |
   | Subscription name                                            | %OrderNextCoreSubscriptionName%       |

5. Click the **Create** button.

6. Add a reference to the **Messages** project.

7. Add a reference to the **Microsoft.Azure.Functions.Worker.Extensions.Storage.Queues** NuGet package.

8. Double-click the **WarehouseMessageHandler.Functions** project to open the WarehouseMessageHandler.Functions.csproj file.

9. Add the `<RootNamespace>Remanufacturing.Warehouse</RootNamespace>` to the `PropertyGroup`. Your csproj file should look similar to:

   ```xml
   <Project Sdk="Microsoft.NET.Sdk">
     <PropertyGroup>
       <TargetFramework>net8.0</TargetFramework>
       <AzureFunctionsVersion>v4</AzureFunctionsVersion>
       <OutputType>Exe</OutputType>
       <ImplicitUsings>enable</ImplicitUsings>
       <Nullable>enable</Nullable>
       <RootNamespace>Remanufacturing.Warehouse</RootNamespace>
     </PropertyGroup>
     <ItemGroup>
       <FrameworkReference Include="Microsoft.AspNetCore.App" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker" Version="1.23.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Http" Version="3.2.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Http.AspNetCore" Version="1.3.2" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.ServiceBus" Version="5.21.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Storage.Queues" Version="5.5.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Sdk" Version="1.17.4" />
       <PackageReference Include="Microsoft.ApplicationInsights.WorkerService" Version="2.22.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.ApplicationInsights" Version="1.3.0" />
     </ItemGroup>
     <ItemGroup>
       <ProjectReference Include="..\..\core\Messages\Messages.csproj" />
     </ItemGroup>
     <ItemGroup>
       <None Update="host.json">
         <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
       </None>
       <None Update="local.settings.json">
         <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
         <CopyToPublishDirectory>Never</CopyToPublishDirectory>
       </None>
     </ItemGroup>
     <ItemGroup>
       <Using Include="System.Threading.ExecutionContext" Alias="ExecutionContext" />
     </ItemGroup>
   </Project>
   ```

10. Right-click the **WarehouseMessageHandler.Functions** project and click **Add** > **New folder**; name the folder Functions.

11. Drag the **Function1.cs** file into the **Functions** folder.

12. Open the **Function1.cs** file and place your cursor on the function's name (`Function1`).

13. Hit the **Ctrl** + **R** + **R** key combination and rename the class to `WarehouseMessageHandler`, ensuring that the `Rename symbol's file` option is selected.

14. Replace the default **WarehouseMessageHandler.cs** contents with:

    ```c#
    using Azure.Messaging.ServiceBus;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;
    using Remanufacturing.Messages;
    using System.Text.Json;
    
    namespace WarehouseMessageHandler.Functions;
    
    public class WarehouseMessageHandler(ILogger<WarehouseMessageHandler> logger)
    {
    
    	private readonly ILogger<WarehouseMessageHandler> _logger = logger;
    
    	[Function(nameof(WarehouseMessageHandler))]
    	[QueueOutput("%WarehouseQueueName%", Connection = "StorageConnectionString")]
    	public async Task<string?> RunAsync(
    		[ServiceBusTrigger("%OrderNextCoreTopicName%", "%OrderNextCoreSubscriptionName%", Connection = "ServiceBusConnectionString")] ServiceBusReceivedMessage message,
    		ServiceBusMessageActions messageActions)
    	{
    		_logger.LogInformation("Message ID: {id}", message.MessageId);
    
    		OrderNextCoreMessage? orderNextCoreMessage = JsonSerializer.Deserialize<OrderNextCoreMessage>(message.Body);
    		if (orderNextCoreMessage == null)
    		{
    			_logger.LogError("Failed to deserialize the message body.");
    			await messageActions.DeadLetterMessageAsync(message);
    			return null;
    		}
    
    		_logger.LogInformation("Order next core for pod {podId}", orderNextCoreMessage.PodId);
    
    		// Complete the message
    		await messageActions.CompleteMessageAsync(message);
    
    		// Queue the order next core message
    		return JsonSerializer.Serialize(orderNextCoreMessage);
    
    	}
    
    }
    ```

15. Hit the **Ctrl** + **Shift** + **B** key combination to build the solution. Fix any errors.

16. Retrieve the Service Bus connection string by:

    1. From the [Azure Portal](htttps://portal.azure.com), search for `sbns-CoolRevive` and select the Service Bus Namespace created during [Lab 0](00-initialize-environment.md).
    2. Click on **Settings** > **Shared access policies**.
    3. Click on **RootManageSharedAccessKey**.
    4. Make note of the Primary Connection String.

17. Get the name of the **Order Next Core** topic by:

    1. Click on **Entities** > **Topics**.
    2. Make note of the full name of the **sbt-coolrevive-ordernextcore** service bus topic.

18. Get the name of the **Inventory Management** subscription by:

    1. Click on the **sbt-coolrevive-ordernextcore** service bus topic.
    2. In the **Subscriptions** listing, make note of the full name of the **sbts-CoolRevive-OrderNextCore** subscription.

19. Get the Azure Storage connection string by:

    1. Search for `stcrreman` and select the Azure Storage account created during [Lab 0](00-initialize-environment.md).
    2. On the left-hand menu, go to **Security +_networking** > **Access keys**.
    3. Make note of one of the connection strings.

20. Add the environment secrets to the Azure Function project by:

    1. Open the local.settings.json file

    2. Add a **ServiceBusConnectionString** key with the primary connection string you noted before.

    3. Add a **OrderNextCoreTopicName** key with the full name of the **sbt-coolrevive-ordernextcore** Service Bus topic.

    4. Add a **OrderNextCoreSubscriptionName** key with the full name of the **sbt-CoolRevive-OrderNextCore** Service Bus topic subscription.

    5. Add a **StorageConnectionString** key with the value of the Azure Storage connection stirng.

    6. Add a **WarehouseQueueName** key with the value of `warehouse`.

       Your local.settings.json file should look similar to the following:

       ```json
       {
         "IsEncrypted": false,
         "Values": {
           "AzureWebJobsStorage": "UseDevelopmentStorage=true",
           "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
           "ServiceBusConnectionString": "<<ServiceBusConnectionString>>",
           "OrderNextCoreTopicName": "<<OrderNextCoreTopicName>>",
           "OrderNextCoreSubscriptionName": "<<OrderNextCoreSubscriptionName>>",
           "StorageConnectionString": "<<StorageConnectionString>>",
           "WarehouseQueueName": "warehouse"
         }
       }
       ```


### Section 2: Create the Warehouse Simulation

We will just simulate the warehouse system, which will read from a queue and send a message to the conveyance blob storage. In a real-world application, this system would be much more involved.

1. Right-click the **Other Systems** solution folder and select **Add** > **New Project...**

2. Search for and select **Azure Functions,** and then click the **Next** button.

3. In the **Configure your new project** dialog, provide the following values and then click the **Next** button.

   | Field        | Value                        |
   | ------------ | ---------------------------- |
   | Project name | OtherSystems                 |
   | Location     | $TargetPath\src\OtherSystems |

4. On the **Additional information** dialog, specify the following values:

   | Field                                                        | Value                                 |
   | ------------------------------------------------------------ | ------------------------------------- |
   | Functions worker                                             | .NET 8.0 Isolated (Long Term Support) |
   | Function                                                     | Queue trigger                         |
   | Use Azureite for runtime storage account (AzureWebJobsStorage) | Checked                               |
   | Enable container support                                     | Unchecked                             |
   | Connection string setting name                               | StorageConnectionString               |
   | Queue name                                                   | %WarehouseQueueName%                  |

5. Click the **Create** button.

6. Add a reference to the **Messages** project.

7. Add a reference to the `Microsoft.Azure.Functions.Worker.Extensions.Storage.Blobs` NuGet package.

8. Double-click the **OtherSystems** project to open the OtherSystems.csproj file.

9. Add the `<RootNamespace>CoolRevive</RootNamespace>` to the `PropertyGroup`. Your csproj file should look similar to:

   ```xml
   <Project Sdk="Microsoft.NET.Sdk">
     <PropertyGroup>
       <TargetFramework>net8.0</TargetFramework>
       <AzureFunctionsVersion>v4</AzureFunctionsVersion>
       <OutputType>Exe</OutputType>
       <ImplicitUsings>enable</ImplicitUsings>
       <Nullable>enable</Nullable>
       <RootNamespace>CoolRevive</RootNamespace>
     </PropertyGroup>
     <ItemGroup>
       <FrameworkReference Include="Microsoft.AspNetCore.App" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker" Version="1.23.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Http" Version="3.2.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Http.AspNetCore" Version="1.3.2" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Storage.Blobs" Version="6.6.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Extensions.Storage.Queues" Version="5.5.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.Sdk" Version="1.17.4" />
       <PackageReference Include="Microsoft.ApplicationInsights.WorkerService" Version="2.22.0" />
       <PackageReference Include="Microsoft.Azure.Functions.Worker.ApplicationInsights" Version="1.3.0" />
     </ItemGroup>
     <ItemGroup>
       <ProjectReference Include="..\..\core\Messages\Messages.csproj" />
     </ItemGroup>
     <ItemGroup>
       <None Update="host.json">
         <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
       </None>
       <None Update="local.settings.json">
         <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
         <CopyToPublishDirectory>Never</CopyToPublishDirectory>
       </None>
     </ItemGroup>
     <ItemGroup>
       <Using Include="System.Threading.ExecutionContext" Alias="ExecutionContext" />
     </ItemGroup>
   </Project>
   ```

10. Replace the default **Program.cs** content with the following:

    ```c#
    using Azure.Storage.Blobs;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.Extensions.Hosting;
    
    BlobServiceClient blobServiceClient = new(Environment.GetEnvironmentVariable("StorageConnectionString")!);
    BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(Environment.GetEnvironmentVariable("ConveyanceContainerName")!);
    
    IHost host = new HostBuilder()
    	.ConfigureFunctionsWebApplication()
    	.ConfigureServices(services =>
    	{
    		services.AddApplicationInsightsTelemetryWorkerService();
    		services.ConfigureFunctionsApplicationInsights();
    		services.AddHttpClient();
    		services.AddSingleton(containerClient);
    	})
    	.Build();
    
    host.Run();
    ```

11. Right-click the **OtherSystems** project and click **Add** > **New folder**; name the folder `Systems`.

12. Drag the **Function1.cs** file into the `Systems` folder.

13. Open the **Function1.cs** file and place your cursor on the function's name (`Function1`).

14. Hit the **Ctrl** + **R** + **R** key combination and rename the class to `Warehouse`, ensuring that the `Rename symbol's file` option is selected.

15. Replace the default **Warehouse.cs** contents with:

    ```c#
    using Azure.Storage.Blobs;
    using Azure.Storage.Queues.Models;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;
    using Remanufacturing.Messages;
    using System.Text;
    using System.Text.Json;
    
    namespace CoolRevive.Systems;
    
    public class Warehouse(ILogger<Warehouse> logger, BlobContainerClient blobContainerClient, IHttpClientFactory httpClientFactory)
    {
    
    	private readonly ILogger<Warehouse> _logger = logger;
    	private readonly BlobContainerClient _blobContainerClient = blobContainerClient;
    	private readonly HttpClient _httpClient = httpClientFactory.CreateClient("NextCoreInTransit");
    
    	[Function(nameof(Warehouse))]
    	public async Task RunAsync([QueueTrigger("%WarehouseQueueName%", Connection = "StorageConnectionString")] QueueMessage message)
    	{
    
    		OrderNextCoreMessage? orderNextCoreMessage = JsonSerializer.Deserialize<OrderNextCoreMessage>(message.Body);
    		if (orderNextCoreMessage == null)
    		{
    			_logger.LogError("WAREHOUSE: Failed to deserialize the message body.");
    			return;
    		}
    
    		_logger.LogInformation("WAREHOUSE: Processing request for pod {podId}", orderNextCoreMessage.PodId);
    
    		// Update the core id and finished product id
    		orderNextCoreMessage.CoreId = Helpers.GenerateRandomString(6);
    		orderNextCoreMessage.FinishedProductId = Helpers.GenerateRandomString(8);
    
    		// Create the blob to signal the conveyance team to move the next core
    		BlobClient blobClient = _blobContainerClient.GetBlobClient($"{Guid.NewGuid()}.json");
    		await blobClient.UploadAsync(new MemoryStream(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(orderNextCoreMessage)), true));
    
    		// Send the message to the next core in transit
    		await Helpers.SendNextCoreInTransitMessageAsync(_httpClient, orderNextCoreMessage);
    
    	}
    
    }
    ```

16. Hit the **Ctrl** + **Shift** + **B** key combination to build the solution. Fix any errors.

17. 

    1. ```json
       {
         "IsEncrypted": false,
         "Values": {
           "AzureWebJobsStorage": "UseDevelopmentStorage=true",
           "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
           "StorageConnectionString": "ServiceBusConnectionString",
           "ConveyanceContainerName": "conveyance",
           "WarehouseQueueName": "warehouse",
         }
       }
       ```


### Section 3: Create the Conveyance Simulation

We will simulate the conveyance system, which will retrieve a message via an Azure Storage blob container and then send a POST HTTP request to the Next Core in Transit API operation.

1. In the **OtherSystems** project, right-click the **Systems** folder, and select **Add** > **New Azure Function...**

2. Name the new Azure Function `Conveyance.cs` and click the **Add** button.

3. Specify the following values:

   | Field                             | Value                     |
   | --------------------------------- | ------------------------- |
   | Function                          | Blob trigger              |
   | Connection string setting name    | StorageConnectionString   |
   | Path                              | %ConveyanceContainerName% |
   | Configure Blob trigger connection | Unchecked                 |

4. Click the **Add** button.

5. Replace the default **Conveyance.cs** contents with:

   ```c#
   using Microsoft.Azure.Functions.Worker;
   using Microsoft.Extensions.Logging;
   using Remanufacturing.Messages;
   using System.Text.Json;
   
   namespace CoolRevive.Systems;
   
   public class Conveyance(ILogger<Conveyance> logger, IHttpClientFactory httpClientFactory)
   {
   
   	private readonly ILogger<Conveyance> _logger = logger;
   	private readonly HttpClient _httpClient = httpClientFactory.CreateClient("NextCoreInTransit");
   
   	[Function(nameof(Conveyance))]
   	public async Task Run([BlobTrigger("%ConveyanceContainerName%", Connection = "StorageConnectionString")] Stream stream, string name)
   	{
   
   		// Read the blob content
   		using StreamReader blobStreamReader = new(stream);
   		string content = await blobStreamReader.ReadToEndAsync();
   
   		// Deserialize the blob content
   		OrderNextCoreMessage? orderNextCoreMessage = JsonSerializer.Deserialize<OrderNextCoreMessage>(content);
   		if (orderNextCoreMessage == null)
   		{
   			_logger.LogError("CONVEYANCE: Failed to deserialize the blob contents.");
   			return;
   		}
   
   		_logger.LogInformation("CONVEYANCE: Processing request for pod {podId}", orderNextCoreMessage.PodId);
   
   		// Send the message to the next core in transit
   		await Helpers.SendNextCoreInTransitMessageAsync(_httpClient, orderNextCoreMessage);
   
   	}
   
   }
   ```

6. Hit the **Ctrl** + **Shift** + **B** key combination to build the solution. Fix any errors.

### Section 4: Prepare the Other Systems Azure Function App for Local Testing

1. Retrieve the Azure Storage connection string by:

   1. From the [Azure Portal](htttps://portal.azure.com), search for `stcrreman` and select the Azure Storage account created during [Lab 0](00-initialize-environment.md).
   2. Click on **Security + networking** > **Access keys**.
   3. Make note of the of one of the connection strings.

2. Retrieve the Order Next Core API URL by:

   1. Search for `apim-coolrevive` and select the Azure API Management instance created during [Lab 0](00-initialize-environment.md).
   2. In the left-hand menu, select **APIs** > **APIs**.
   3. Select the **Order Next Core** API.
   4. Click on the **Test** tab.
   5. Select the **Next Core in Transit** operation.
   6. Make a note of the **Request URL**.

3. Retrieve the Azure API Management subscription key by:

   1. In the left-hand menu of the `apim-coolrevive` API Management instance, select **APIs** > **Subscriptions**.
   2. Click on the ellipsis button on the `Remanufacturing` table entry and select **Show/hide keys**.
   3. Make note of one of the keys.

4. Add the environment secrets to the Azure Function project by:

   1. Open the local.settings.json file

   2. Add a **StorageConnectionString** key with the primary connection string you noted before.

   3. Add a **ConveyanceContainerName** key with the the value of `conveyance`.

   4. Add a **WarehouseQueueName** key with the value of `warehouse`.

   5. Add a **ConveyanceContainerName** key with the the value of `conveyance`.

   6. Add a **OrderNextCoreUrl** key with the value of the Order Next Core API URL.

   7. Add a **SubscriptionKeyKey** key with the value of `Ocp-Apim-Subscription-Key`.

   8. Add a **SubscriptionKeyValuue** key with the value of the API Management subscription key noted above.

      Your local.settings.json file should look similar to the following:

      ```json
      {
        "IsEncrypted": false,
        "Values": {
          "AzureWebJobsStorage": "UseDevelopmentStorage=true",
          "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
          "StorageConnectionString": "<<StorageConnectionString>>",
          "WarehouseQueueName": "warehouse",
          "ConveyanceContainerName": "conveyance",
          "OrderNextCoreApiUrl": "<<OrderNextCoreApiUrl>>",
          "SubscriptionKeyKey": "Ocp-Apim-Subscription-Key",
          "SubscriptionKeyValue": "<<SubscriptionKeyValue>>"
        }
      }
      ```

   9. Configure the startup projects for the solution by:

      1. Right-click on the **Remanufacturing** solution and selecting **Configure Startup Projects...**
      2. Select the **Multiple startup projects** option.
      3. Specify that the following projects are to Start:
         - GetNextCore.Functions
         - GetNextCoreHandler.Functions
         - InventoryManager.Functions
         - OtherSystems
         - WarehouseManagerHandler.Functions
      4. Click the **OK** button.
   
   ## Conclusion
   
   In this lab, we have successfully created a series of Azure Functions that simulate the warehouse and conveyance systems as used by the Remanufacturing domain. By leveraging Azure Service Bus topics, Azure Storage queues, and Azure Storage blobs, we have established a robust communication framework that enables the Order Next Core workflow to interact seamlessly with these "external" systems.
   
   The **Warehouse Message Handler** function demonstrates how to process incoming messages from the Order Next Core system and queue them for further processing. This function is critical in ensuring that orders are handled efficiently and without delay.
   
   The **Warehouse** simulation function provides a practical example of how to simulate the warehouse system's behavior. It reads from a queue and sends messages to the conveyance blob storage, mimicking the real-world scenario where orders are prepared for conveyance. The function also uses an HTTP endpoint to send messages back to the Remanufacturing system regarding the request status.
   
   The **Conveyance** simulation function provides a practice example of how to simulate the conveyance system's behavior. It reads from a blob storage container to process its work and deliver the core. The function also uses an HTTP endpoint to send messages back to the Remanufacturing system to indicate the status of the request.
   
   Through this lab exercise, we have gained valuable insights into the development and configuration of Azure Functions with different triggers. We have also learned how to integrate these functions with other Azure services, such as Azure Service Bus and Azure Storage, to create a cohesive and scalable solution.
   
   This exercise has enhanced our understanding of Azure Functions and provided us with hands-on experience in developing cloud-based applications that can handle complex workflows and data processing tasks. As we continue to explore the capabilities of Azure, we are better equipped to design and implement solutions that meet the evolving needs of modern businesses.
