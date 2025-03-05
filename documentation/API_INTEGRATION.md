<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: CC-BY-4.0
License-Filename: LICENSES/CC-BY-4.0.txt
-->

# Citykey API Integration Guide

## Core Architecture
- Citykey uses native NSURLSession for network management
- APIs are organized by service domains (e.g., Waste Calendar, Digital Administration)
- App follows MVP (Model-View-Presenter) architecture pattern

## Integration Process
1. **Create a Service Worker**
    - Each service requires its own dedicated worker class
    - All APIs related to a specific service are implemented within its worker
2. **API Implementation**
    - Implement service-specific API endpoints in the worker class
    - Use native NSURLSession for network requests
    - Handle response parsing and error management
3. **Service Consumption**
    - Inject the appropriate worker into ViewModels that need the service
    - ViewModels communicate with workers to fetch/send data
    - Presenters update the Views based on data from ViewModels

## Adding a new service tile in city key App
The Citykey app provides various city services through a modular architecture where each service is defined in a JSON response. This documentation will help you understand the API structure and how to integrate new services into the app. 

## API Structure  
**Base Response Format**: 
```sh
{ 
  "content": [{ 
    "cityServiceCategoryList": [ 
      { 
        "categoryId": string, 
        "category": string, 
        "icon": string, 
        "image": string, 
        "description": string, 
        "cityServiceList": [Service] 
      } 
    ], 
    "cityId": number 
  }] 
} 
```

**Service Object Structure**:
```sh
{ 
  "serviceId": number, 
  "service": string, 
  "description": string, 
  "icon": string, 
  "image": string, 
  "function": string, 
  "serviceType": string, 
  "isNew": boolean, 
  "new": boolean, 
  "residence": boolean, 
  "restricted": boolean, 
  "serviceParams": { 
    // Optional parameters specific to the service 
  }, 
  "serviceAction": [Action], 
  "templateId": number 
} 
```
**Action Object Structure**:
```sh
{ 
  "actionId": number, 
  "action": string, 
  "actionOrder": number, 
  "androidUri": string, 
  "buttonDesign": string, 
  "iosAppStoreUri": string, 
  "iosUri": string, 
  "visibleText": string, 
  "actionType": string 
} 
```
## Required Fields
**Category Fields**
**categoryId**: Unique identifier for the service category 
**category**: Display name of the category 
**description**: Brief description of the category 
**cityServiceList**: Array of services within this category 

**Service Fields**
**serviceId**: Unique identifier for the service 
**service**: Display name of the service 
**description**: HTML-formatted description of the service 
**function**: Service type identifier used for routing 
**serviceType**: Classification of the service 
**restricted**: Boolean indicating if the service requires authentication 

**Action Fields**:
**actionId**: Unique identifier for the action 
**actionOrder**: Order in which actions should be displayed 
**iosUri**: URI scheme or URL for handling the action 
**visibleText**: Button text to display 
**actionType**: Type of action to perform 

## Testing Your Integration: 
1. Add your service JSON to the mock response file 
2. Build and run the app 
3. Verify your service appears in the correct category 
4. Test all actions and links 
5. Verify the service description renders correctly 
6. Test both authenticated and unauthenticated scenarios if applicable 
