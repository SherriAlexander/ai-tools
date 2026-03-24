---
name: 'XMC Sitecore Rendering Creation Instructions'
description: 'Instructions for creating Sitecore renderings using SPE scripts.'
applyTo: '**/*.ps1'
---

# Sitecore Rendering Creation
A sitecore rendering is a reusable component that can be added to pages within the Sitecore content management system. When creating a Sitecore rendering item, it is essential to define at least the rendering definition which will represent the entity on the page where the user interface, design and interaction are built. There are several other key elements that are optional and may be required to ensure that the rendering functions correctly and meets the rendering requirements. The following sections outline the variables and data structures you must define and pre-existing functions you may use to create a Sitecore rendering using Sitecore Powershell Extension (SPE) scripts.

## SCRIPT HEADER : REQUIRED
To call the pre-existing SPE functions, it is required to include a script header that imports the necessary variables and functions required for the rendering creation process. The script header should include the following:

### Example : script header
```powershell
# <jira-key> : <rendering-name>

Get-Item -Path "master:" -ID "{FB25AA0F-AB22-46E4-80A7-512423378337}" | Invoke-Script # Devices
Get-Item -Path "master:" -ID "{56EDD942-A2E1-476B-AE4F-A13B9E3A9437}" | Invoke-Script # Item Ids
Get-Item -Path "master:" -ID "{2BFE54C1-1B01-4833-AAC3-07926E18C606}" | Invoke-Script # Lookups
Get-Item -Path "master:" -ID "{0BA7264C-D872-43D8-B61E-C909B7BE58F7}" | Invoke-Script # Paths
Get-Item -Path "master:" -ID "{80BD81F4-E138-420A-BE4D-88F483924957}" | Invoke-Script # Template Ids

Import-Function Add-RenderingToPlaceholderSettings
Import-Function Create-Rendering
Import-Function Set-ItemField
Import-Function Create-ItemIfNotExists
Import-Function Write-SectionEntry
Import-Function Write-SectionHeader
Import-Function Create-SiteSetupItems
Import-Function Confirm-ListContainsField
Import-Function Create-RenderingVariant
Import-Function Create-DatasourceBranchTemplate
Import-Function Create-DatasourceFolderTemplate
Import-Function Create-DatasourceTemplate
Import-Function Create-DictionaryEntries
Import-Function Create-RenderingParametersTemplate
Import-Function Create-StandardValues
Import-Function Get-MatchingBaseTemplates
```

## RENDERING GROUP : REQUIRED
When creating a Sitecore rendering item, it is essential to organize the rendering into a rendering group. A rendering group is a parent folder within Sitecore that helps categorize and manage renderings based on their functionality or purpose. This organization aids content authors in easily locating and selecting the appropriate rendering when building pages. The rendering group should be a powershell variable that will be used when creating the datasource template, parameters template and rendering definition.

### Example : rendering group variable definition
The name of the rendering group should be defined in a variable for use in the functions that create the rendering and other related elements. This value should be derived from within the JIRA ticket. The rendering group should be prefixed with "VXA". For example if the rendering group is "Listings", then $renderingGroup should be set to "VXA Listings". 

```powershell
$renderingGroup = <rendering-group-name>
```

## RENDERING NAME : REQUIRED
When creating a Sitecore rendering item, it is essential to define the rendering name. The rendering name is a unique identifier for the rendering within Sitecore and is used by content authors to select and add the rendering to pages. The rendering name should be a powershell variable that will be used when creating the datasource template, parameters template and rendering definition. This value should be derived from the JIRA ticket title.

### Example : rendering name definition

```powershell
$renderingName = <rendering-name>
```

## ICON : REQUIRED
When creating a Sitecore datasource template and rendering item, an icon could be set to help users easily identify it within the Sitecore content management system. The icon should be a powershell variable that will be used when creating the rendering definition. The icon value should be located in the ticket under 'Authoring Considerations'. An example path might look like one of these: 

* Office/32x32/keyboard_key_g.png
* Office/32x32/messages.png
* /~/icon/office/32x32/books.png
* /~/icon/office/32x32/map_route.png
* /~/icon/software/32x32/text_code_delete.png
* /~/icon/applicationsv2/32x32/bookmark_blue_edit.png
* /-/media/6c8f87cd976e4fd6b9813c121037651a.ashx?thn=1&&db=master
* /-/media/9abdc18798af47dc86ab2f0975fdf42c.ashx?thn=1&&db=master
* /-/media/fb3d1e61682a4dd09472092233201c9d.ashx?thn=1&&db=master

The full icon path should be converted to a relative path by removing the leading /~/icon/ portion of the path. So the above examples would become: office/32x32/books.png, office/32x32/map_route.png, software/32x32/text_code_delete.png and applicationsv2/32x32/bookmark_blue_edit.png respectively. The path that includes /-/media/ is a different type of path and should be used as-is without modification.

If the ticket doesn't mention it or says it is 'TBD' or to be decided later, then set the icon variable to an empty string.

### Example : icon that's defined
```powershell
$icon = "office/32x32/books.png"
```

### Example : another icon that's defined
```powershell
$icon = "office/32x32/map_route.png"
```

### Example : another icon with the media format
```powershell
$icon = "* /-/media/fb3d1e61682a4dd09472092233201c9d.ashx?thn=1&&db=master"
```

### Example : icon that's undefined
```powershell
$icon = ""
```

## DATASOURCE TEMPLATE : OPTIONAL
When defining a rendering, the component may need to store data for content authors to modify the content of the rendering. You may need to define a datasource template that is an item created along with a rendering to store it's data. Sitecore will manage the creation and relationship to the component when it is added to a page. This template defines the fields and structure of the datasource item that content authors will populate. The datasource template should be created using the Create-DatasourceTemplate function in the SPE scripts. The datasource name should be taken from the rendering name being created. The datasource template should be a powershell variable that will be used when creating the rendering definition. If a section is not defined, the default value for a section is "Data". The "Styling" section is commonly used to group fields that control the visual appearance of the component and should be used when defining fields the rendering parameters template definition but ignored for the datasource template. 

### Example : page fields
The Jira ticket may reference page fields. Pages are defined as template separately in other tickets and their fields are also in a similar table format. If a component is used on a page, Sitecore will maintain that relationship and allow the component to access the page fields. If the 'Mapping' value mentions that it's a 'Page-level field', then that field should not be included in the datasource template definition because it's available to the rendering already.

### Example : datasource definition
This is how a data table would be represented in powershell. Use this as a guide but always refer to the JIRA ticket for the specific values and not this example. This is only a guide to demonstrate the structure. The datasource definition item should include all table properties even if they are empty and those properties are: name, title, section, fieldType, fieldSource, required, defaultValue.

```powershell
$datasourceDefinition = @(
    @{
        name            = "title"
        title           = "Title"
        section         = "Data"
        fieldType       = "Single-Line Text"
        fieldSource     = ""
        required        = $true
        defaultValue    = "`$name"
    },
    @{
        name            = "link"
        title           = "Link"
        section         = "Data"
        fieldType       = "General Link"
        fieldSource     = ""
        required        = $false
        defaultValue    = ""
    }
)
```

```powershell
$datasourceDefinition = @(
    @{
        name            = "articleSelector"
        title           = "Article Selector"
        section         = "Data"
        fieldType       = "Treelist"
        fieldSource     = ""
        required        = $false
        defaultValue    = ""
    }
)
```

### Example : creating a datasource template using the Create-DatasourceTemplate function
the icon variable defined earlier should be passed into the function using the -icon parameter.
```powershell
$datasourceItem = Create-DatasourceTemplate `
    -renderingGroup $renderingGroup `
    -datasourceName $renderingName `
    -datasourcePath $vxaDatasourceTemplatePath `
    -datasourceDefinition $datasourceDefinition `
    -icon $icon
```

## MANAGED ITEM DATASOURCE TEMPLATE : OPTIONAL
When defining a component's datasource item in Sitecore, the datasource may have one or many child item datasources that are identified as a 'Managed Item'. This is an additional datasource template that will need to be created and the resulting item ID passed into the Create-DatasourceTemplate function. This must be placed before the Create-DatasourceTemplate call so that the -managedItemTemplateId parameter can be set using the $managedDatasourceItem.Id value. The managed item template is used when the component's datasource will have child items that are created and managed by the content author.

### Example : creating a managed datasource template and datasource template
the icon variable defined earlier should be passed into the Create-DatasourceTemplate function using the -icon parameter for the datasource item but the managed datasource item should have a fixed icon of "Office/32x32/window.png".
```powershell
$managedDatasourceItem = Create-DatasourceTemplate `
    -renderingGroup $renderingGroup `
    -datasourceName "$($renderingName) Item" `
    -datasourcePath $vxaDatasourceTemplatePath `
    -datasourceDefinition $managedDatasourceDefinition `
    -icon "Office/32x32/window.png"

$datasourceItem = Create-DatasourceTemplate `
    -renderingGroup $renderingGroup `
    -datasourceName $renderingName `
    -datasourcePath $vxaDatasourceTemplatePath `
    -datasourceDefinition $datasourceDefinition `
    -managedItemId $managedDatasourceItem.ID `
    -icon $icon
```

## DATASOURCE BRANCH TEMPLATE : OPTIONAL
If it is determined that both a datasource template and a managed datasource item template are required, another condition may apply. Look for phrases in the the ticket requirements mentioning needing items loaded by default such as 'by default, <number> items will load when the component is added to a page', or 'by default <number> <renderingName> items are included when the component is created'. This would indicate that a datasource branch template will be required. 

The datasource branch template is an instance of the datasource with a set of managed items configured as a preset to make copies from. The datasource branch template should be created using the Create-DatasourceBranchTemplate function. The datasource item will be provided through the -datasourceItem parameter. The location where to create the branch template will be passed using the -datasourceBranchPath and will be set to a global variable that will be the same for all scripts. The number of managed items to create should be determined from the ticket requirements and set as a powershell variable and passed in using the -numberOfManagedItems parameter. The ID of the managed datasource item will be passed using the -managedItemId parameters. The icon will also be passed in using the -icon parameter. 

### Example : creating a managed datasource template and datasource template
```powershell
$numberOfManagedItems = <number-of-managed-items>

$datasourceBranchItem = Create-DatasourceBranchTemplate `
    -datasourceBranchPath "$($vxaDatasourceBranchTemplatePath)/$($renderingGroup)" `
    -datasourceItem $datasourceItem `
    -numberOfManagedItems $numberOfManagedItems `
    -managedItemId $managedDatasourceItem.ID `
    -icon $icon
```

## DATASOURCE FOLDER TEMPLATE : OPTIONAL
When defining a component's datasource item in Sitecore, JIRA will indicate if the component can be sourced from either a local Data folder, from a shared folder or both. If the component will use a shared folder then a datasource folder template will need to be created for that shared location. The datasource folder template should be created using the Create-DatasourceFolderTemplate function in the SPE scripts. The datasource folder name should be taken from the rendering name being created with " Folder" appended to it and passed in with the -datasourceFolderName parameter. The datasource item id will need to be provided using the -datasourceTemplateId parameter and the -datasourceFolderPath will be a global variable that will be the same for all scripts. Creating a datasource folder will return a  datasource folder template item that should be set to a powershell variable named $datasourceFolderItem and that will be used when creating site setup items.

### Example : creating a datasource folder template using the Create-DatasourceFolderTemplate function
```powershell
$datasourceFolderItem = Create-DatasourceFolderTemplate `
    -renderingGroup $renderingGroup `
    -datasourceFolderName "$($renderingName) Folder" `
    -datasourceFolderPath $vxaDatasourceTemplatePath `
    -datasourceTemplateId $datasourceItem.ID
```

## RENDERING VARIANT : OPTIONAL
Some components may defined multiple layout variants that users can select from. If more than one variant will be defined then the primary ticket will become the default variant and the other referenced tickets will become the named variants. You will need to load the referenced tickets to identify what their variant name will be. When you create a rendering variant you will use the Create-RenderingVariant function and pass in the previously defined $renderingGroup and $renderingName variables using the -renderingGroup and -renderingName parameters respectively. The -branchFolderPath will be set using a global variable that will remain the same for all scripts. The -variantNames will be a list of strings for any other variants other than the default variant. If there are no other variants then this function does not need to be called. Creating a rendering variant will return a rendering variant item that should be set to a powershell variable named $renderingVariantItem and that will be used when creating site setup items.

### Example : creating a rendering variant branch template
```powershell
$renderingVariantItem = Create-RenderingVariant `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -branchFolderPath $vxaDatasourceBranchTemplatePath `
    -variantNames @("variant name from another", "another variant from a different ticket")
```

## SITE SETUP ITEMS : OPTIONAL
When defining a component's rendering item in Sitecore, you may need to create site setup items that tell Sitecore to include the component data folder or rendering variants at a site level when new websites are added to the system. This allow content authors to share components across pages or select from multiple variants of a component. The site setup items should be created using the Create-SiteSetupItems function in the SPE scripts. The site setup items will include an "Add Item" for the datasource folder and an "Add Item" for the rendering variant if applicable. The datasource folder "Add Item" allows content authors to create new datasource items based on the defined datasource template when adding the component to a page. The rendering variant "Add Item" allows content authors to select the appropriate rendering variant when adding the component to a page. If neither the datasource folder or rendering variant are created then this function does not need to be called. If either is created then this function should be called with the parameters that were created. If one of the parameters is not created then an empty string "" should be passed to that parameter.

### Example : creating site setup items with only the datasource folder
```powershell
Create-SiteSetupItems `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -datasourceFolderId $datasourceFolderItem.ID `
    -renderingVariantId ""
```

### Example : creating site setup items with only the rendering variant
```powershell
Create-SiteSetupItems `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -datasourceFolderId "" `
    -renderingVariantId $renderingVariantItem.ID
```

### Example : creating site setup items with both the datasource folder and rendering variant
```powershell
Create-SiteSetupItems `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -datasourceFolderId $datasourceFolderItem.ID `
    -renderingVariantId $renderingVariantItem.ID
```

## RENDERING PARAMETERS TEMPLATE : OPTIONAL
When defining a rendering, the component may need to store configuration settings for content authors to modify the behavior or appearance of the rendering. If a 'styling' section is added to the datasource template or there is a separate data table for rendering parameters, then a rendering parameters template will need to be created. This template defines the fields and structure of the rendering parameters item that content authors will populate. The rendering parameters template should be created using the Create-RenderingParametersTemplate function in the SPE scripts. The rendering parameters name should be taken from the name of the component being created with " Parameters" appended to it. The rendering parameters template should be a powershell variable that will be used when creating the rendering definition. If there are no fields for the rendering parameters, then you do not need to create a rendering parameters template. If you don't create a rendering parameters template then you can pass an empty string "" to the -parametersTemplateId parameter in the Create-Rendering function. Rendering parameters templates are only associated with the datasource definition and not the managed item datasource definition. If a managed item datasource definition has a styling section it should just be used to create fields directly on that item. 

### Example : list of objects with fields that define a rendering parameters template definition
The rendering parameters definition item should include all fields even if they are empty and those fields are: name, title, section, fieldType, fieldSource, required, defaultValue.

Field types should match the exact naming convention used in Sitecore as outlined in the datasource template section earlier.

```powershell
$renderingParametersDefinition = @(
    @{
        name            = "numberOfColumns"
        title           = "Number of Columns"
        section         = "Data" 
        fieldType       = "Droplink"
        fieldSource     = ""
        required        = $false
        defaultValue    = ""
    },
    @{
        name            = "theme"
        title           = "Theme"
        section         = "Styling" 
        fieldType       = "Droplink"
        fieldSource     = ""
        required        = $false
        defaultValue    = ""
    }
)

$renderingParametersItem = Create-RenderingParametersTemplate `
    -renderingGroup $renderingGroup `
    -renderingParametersName "$($renderingName) Rendering Parameters" `
    -renderingParametersPath $vxaDatasourceTemplatePath `
    -renderingParametersDefinition $renderingParametersDefinition
```

### Example : if a rendering variant is created, the flag -hasVariant should be added.
If a rendering variant is created for the component then the -hasVariant flag should be added to the Create-RenderingParametersTemplate function call. This will ensure that the rendering parameters template is associated with the rendering variants.
```powershell
$renderingParametersItem = Create-RenderingParametersTemplate `
    -renderingGroup $renderingGroup `
    -renderingParametersName "$($renderingName) Rendering Parameters" `
    -renderingParametersPath $vxaDatasourceTemplatePath `
    -renderingParametersDefinition $renderingParametersDefinition `
    -hasVariant
```

## RENDERING DEFINITION : REQUIRED
When defining a component's rendering item in Sitecore, it is essential to create the rendering definition that represents the entity on the page where the user interface, design, and interaction are built. The rendering definition should be created using the Create-Rendering function in the SPE scripts. The rendering definition requires several parameters to ensure that it functions correctly and meets the rendering requirements. The following list outlines the required and optional parameters for creating a rendering definition. The icon variable defined earlier should be passed into the function using the -icon parameter.

### OTHER PROPERTIES : REQUIRED
When defining a component's rendering item in Sitecore, it is essential to include other properties to ensure that the behavior of the component in the authoring environment is as expected. The other properties store a value that is either "true" or "false". These are not powershell booleans and should not be populated with values like $true or $false. Only use the string value. The following list are the properties and their description to help determine when constructing the -otherProperties parameter for the Create-Rendering function.

#### Property Definition
- IsRenderingsWithDynamicPlaceholders: When set to true, the IsRenderingsWithDynamicPlaceholders property enables the resolving of the dynamic placeholders and the components inside of them. This is particularly useful in scenarios where you have components that contain placeholders and that component will be added to a page multiple times. Each placeholder within the component will have a unique key to allow components added to those placeholders to be uniquely identified.
- UsePlaceholderDatasourceContext: When set to true, the UsePlaceholderDatasourceContext property allows a rendering within a placeholder to inherit the datasource of its parent rendering or a specific context item. This is particularly useful in scenarios where you have nested components and want the child components to operate with knowledge of the parent's data. 
- IsAutoDatasourceRendering: When set to true, the IsAutoDatasourceRendering property will automatically create a local datasource item when the component is added to a page. This is only required when the component is designed to have a datasource item and the content author should not be required if none exists.

#### Example : other properties definition
```powershell
$otherProperties = @(
    @{ key = "IsRenderingsWithDynamicPlaceholders"; value = "false" },
    @{ key = "UsePlaceholderDatasourceContext"; value = "false" },
    @{ key = "IsAutoDatasourceRendering"; value = "true" }
)
```

### DATASOURCE LOCATION : OPTIONAL
When defining a component's rendering item in Sitecore, you may need to define the datasource location. The datasource location specifies where content authors can select or create datasource items when adding the rendering to a page. This helps ensure that the rendering is populated with relevant content and maintains consistency across the site. The datasource location should be a powershell variable that will be used when creating the rendering definition. The datasource location can include multiple paths separated by a pipe (|) character. Common locations include site-specific data folders and shared data folders. The ticket may specify that the rendering may only be sourced from a local Data folder. This means that the datasource location should be set to './Data/'. If there is no datasource template created then set the datasource location to an empty string "".

#### Example : datasource location variable definition with both site and shared site locations
```powershell
$datasourceLocation = "query:`$site/*[@@name='Data']/*[@@templatename='$($renderingName) Folder']|query:`$sharedSites/*[@@name='Data']/*[@@templatename='$($renderingName) Folder']"
```

#### Example : datasource location variable definition with only local Data folder location
```powershell
$datasourceLocation = "./Data/"
```

#### Example : datasource location variable definition with no datasource template created
```powershell
$datasourceLocation = ""
```

### RENDERING CONTENTS RESOLVER : REQUIRED
When defining a component's rendering item in Sitecore, you should define the rendering contents resolver. The rendering contents resolver determines how the content for the rendering is retrieved and displayed on the page. There are several types of rendering contents resolvers available in Sitecore, each serving a specific purpose. The following list outlines the common rendering contents resolvers and their descriptions to help determine which one to use when constructing the -renderingContentsResolverName parameter for the Create-Rendering function. 

**Resolver Selection Rules:**
- If the datasource template has **NO fields** and only managed items have fields (datasource with children), then use the **"Datasource Item Children Resolver"** with **Layout Service** data model
- If the datasource template has **fields and NO managed items**, then use the **"Datasource Resolver"** with **Layout Service** data model  
- If the datasource has **both fields AND managed items**, then set the resolver value to empty (which defaults to manual GraphQL query) and use **GraphQL** data model to manually construct the GraphQL query to include parent fields, managed items, and possibly context item fields if needed

#### Rendering Contents Resolvers Options
- Context Item Children Resolver : Retrieves all the child items of the context item (this is usually the page on which the component is rendered). Used to display a list of child elements, such as when creating a navigation menu or a list of related articles.
- Context Item Resolver : Retrieves content from the context item, which is usually the page on which the component is rendered. Used to display content directly from the page itself.
- Datasource Item Children Resolver : Retrieves all the children of the datasource assigned to the component, and not the parent. This resolver is useful in cases where you don't want to render the datasource parent (for example, in a gallery display, only render the images saved as children, but not the parent which contains information about the gallery item).
- Datasource Resolver : Retrieves content from the component datasource. This is the default rendering behavior when no resolver is assigned.
- Folder Filter Resolver : Retrieves the children of a datasource, while excluding folders. This is useful for sorting and organizing items in folders, without rendering the folder items, only their content.
- Navigation Contents Resolver : If you apply this resolver, make sure you select the one in the Headless Experience Accelerator folder and not the one in the Experience Accelerator folder. It retrieves content that is used in navigational components, such as menus or breadcrumbs. It can pull items based on their hierarchy in the content tree, ensuring that the site structure is accurately reflected in the navigation.

#### Example : manual override of rendering contents resolver
```powershell
$renderingContentsResolverName = ""
```

#### Example : rendering contents resolver for datasource item
```powershell
$renderingContentsResolverName = "Datasource Resolver"
```

#### Example : rendering contents resolver for context item children
```powershell
$renderingContentsResolverName = "Navigation Contents Resolver"
```

### GRAPHQL QUERY : OPTIONAL
When creating Sitecore components that will be used in a headless architecture with GraphQL, then follow the pattern of condensing the template name and use capital camel casing on type objects to ensure that the components are compatible with GraphQL queries and can effectively expose the necessary data. This only needs to be created if the rendering contents resolver is empty or if the ticket specifically requests a custom GraphQL query. The GraphQL query should be a powershell variable that will be used when creating the rendering definition. 

#### Example : GraphQL query for datasource and managed items
```GraphQL
$graphQLQuery = @"
query ComponentNameQuery($datasource: String!, $language: String!) {
  datasource: item(path: $datasource, language: $language) {
    firstDatasourceFieldName:field(name:"firstDatasourceFieldName") {jsonValue}
    secondDatasourceFieldName:field(name:"secondDatasourceFieldName") {jsonValue}
    children {
      results {
        firstManagedItemFieldName:field(name:"firstManagedItemFieldName") {jsonValue}
        secondManagedItemFieldName:field(name:"secondManagedItemFieldName") {jsonValue}
        thirdManagedItemFieldName:field(name:"thirdManagedItemFieldName") {jsonValue}
      }
    }
  }
}
"@
```

#### Example : GraphQL with datasource and context item fields
```GraphQL
$graphQLQuery = @"
query ComponentNameQuery($datasource: String!, $contextItem: String!, $language: String!) {
  datasource: item(path: $datasource, language: $language) {
    firstDatasourceFieldName:field(name:"firstDatasourceFieldName") {jsonValue}
  }
  contextItem: item(path: $contextItem, language: $language) {
    firstContextItemFieldName:field(name:"firstContextItemFieldName") {jsonValue}
    secondContextIFieldName:field(name:"secondContextIFieldName") {jsonValue}
  }
}
"@
```

#### Example : GraphQL with datasource, managed items and context item fields
```GraphQL
$graphQLQuery = @"
const myGraphQLQuery = `
query ComponentNameQuery($datasource: String!, $contextItem: String!, $language: String!) {
  datasource: item(path: $datasource, language: $language) {
    firstDatasourceFieldName:field(name:"firstDatasourceFieldName") {jsonValue}
    children {
      results {
        firstManagedItemFieldName:field(name:"firstManagedItemFieldName") {jsonValue}
        secondManagedItemFieldName:field(name:"secondManagedItemFieldName") {jsonValue}
      }
    }
  }
  contextItem: item(path: $contextItem, language: $language) {
    firstContextItemFieldName:field(name:"firstContextItemFieldName") {jsonValue}
    secondDatasourceFieldName:field(name:"secondDatasourceFieldName") {jsonValue}
  }
}
"@
```

#### Example : GraphQL with two level nested managed items
```GraphQL
$graphQLQuery = @"
query ComponentNameQuery($datasource: String!, $language: String!) {
  datasource: item(path: $datasource, language: $language) {
    firstDatasourceFieldName:field(name:"firstDatasourceFieldName") {jsonValue}
    secondDatasourceFieldName:field(name:"secondDatasourceFieldName") {jsonValue}      
    children {
      results {
        firstManagedItemFieldName:field(name:"firstManagedItemFieldName") {jsonValue}
        secondManagedItemFieldName:field(name:"secondManagedItemFieldName") {jsonValue}
        children {
          results {
            firstSubItemFieldName:field(name:"firstSubItemFieldName") {jsonValue}
            secondSubItemFieldName:field(name:"secondSubItemFieldName") {jsonValue}
          }
        }
      }
    }
  }
}"@
```

### Datasource Template ID : OPTIONAL AND CONDITIONAL
To properly set the -datasourceTemplatePath parameter, you will need to determine if a datasource template was created earlier and if a datasource branch template was created for that datasource template. If both were created, then the -datasourceTemplatePath parameter should be set using the datasource branch item. If only the datasource template was created, then the datasource template should used. If no datasource template was created, then an empty string "" should be passed to the -datasourceTemplatePath parameter in the Create-Rendering function.

### Example : creating a rendering definition with no datasource template
```powershell
$renderingItem = Create-Rendering `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -renderingPath $vxaRenderingsPath `
    -otherProperties $otherProperties `
    -parametersTemplateId $renderingParametersItem.ID `
    -datasourceLocation $datasourceLocation `
    -datasourceTemplatePath "" `
    -graphQLQuery $graphQLQuery `
    -renderingContentsResolverName $renderingContentsResolverName `
    -icon $icon
```

### Example : creating a rendering definition with only the datasource template
```powershell
$renderingItem = Create-Rendering `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -renderingPath $vxaRenderingsPath `
    -otherProperties $otherProperties `
    -parametersTemplateId $renderingParametersItem.ID `
    -datasourceLocation $datasourceLocation `
    -datasourceTemplatePath $datasourceItem.FullPath `
    -graphQLQuery $graphQLQuery `
    -renderingContentsResolverName $renderingContentsResolverName `
    -icon $icon
```

### Example : creating a rendering definition with both the datasource template and datasource branch template
```powershell
$renderingItem = Create-Rendering `
    -renderingGroup $renderingGroup `
    -renderingName $renderingName `
    -renderingPath $vxaRenderingsPath `
    -otherProperties $otherProperties `
    -parametersTemplateId $renderingParametersItem.ID `
    -datasourceLocation $datasourceLocation `
    -datasourceTemplatePath $datasourceBranchItem.FullPath `
    -graphQLQuery $graphQLQuery `
    -renderingContentsResolverName $renderingContentsResolverName `
    -icon $icon
```

## ADD RENDERING TO CONTAINERS : OPTIONAL
The rendering may also include instructions in the 'Authoring Considerations' section about what containers the rendering should be added to. Containers are also named renderings that are defined in their own tickets. You should inspect the tickets referenced and determine their name and create an array of container names that will be provided to the Add-RenderingToPlaceholderSettings function with the -containerNames parameter. The names may vary in the ticket reference so you should select the name of the container from the list of acceptable name options by choosing which one most closely matches the ticket reference. The following is a list of acceptable container names: 
* Container Full Bleed
* Container Full Width
* 30 Percent Container
* 50 Percent Container
* 70 Percent Container

The rendering may also include a list of which pages to apply those containers to. The names may vary in the ticket reference so you should select the name of the page from the list of acceptable name options by choosing which one most closely matches the ticket reference. The following is a list of acceptable page names: 
* Detail Page
* Event Detail Page
* Homepage
* Landing Page
* Search Page
* Structured Content Page

The $placeholderPaths is a set of global variables and can be used as-is, shouldn't be modified and can be passed to the function using the -placeholderPaths parameter. The $rendering.ID from the previous function should be passed into the function using the -renderingId parameters. 

If you cannot find any reference to containers in the 'Authoring Considerations' section of the ticket, then you do not need to call this function.

### Example : adding a rendering to a list of containers with the Add-RenderingToPlaceholderSettings function
```powershell
$containerNames = @(
    "Acceptable Container Name 1",
    "Acceptable Container Name 2",
    "Acceptable Container Name 3"
)

$pagenames = @(
  "Acceptable Page Name 1",
  "Acceptable Page Name 2"
)

$placeholderPaths = @(
    $vxaPlaceholderSettingsPath
)

Add-RenderingToPlaceholderSettings
    -containerNames $containerNames `
    -placeholderPaths $placeholderPaths `
    -pageNames $pageNames `
    -renderingId $renderingItem.ID
```

## DICTIONARY TEXT ENTRIES : OPTIONAL
The ticket requirements may mention that one or many dictionary text entries will need to be created for the rendering. If the ticket mentions dictionary text entries, you should create them using the Create-DictionaryEntries function. The rendering group arameter should be the one created earlier. The dictionary path should be the global variable value $vxaDictionaryBranchPath. The rendering name should be the name already selected and used earlier and the dictionaryEntries should be a json array of objects with three properties: name, key and phrase. The name should be a camel case name that concisely describes what it is for. The key should be a camel case version of the rendering group concatenated with the name using an underscore as a delimiter. The phrase should be the actual text that will be displayed in the rendering. If there are no dictionary text entries mentioned in the ticket, then you do not need to call this function.

### Example : creating dictionary entries
```powershell
$dictionaryEntries = @(
    @{
        name   = "shareText"
        key    = "<renderingName>_shareText"
        phrase = "Share"
    },
    @{
        name   = "searchPlaceholderText"
        key    = "<renderingName>_searchPlaceholderText"
        phrase = "Search..."
    }
)

Create-DictionaryEntries `
  renderingGroup $renderingGroup `
  renderingName $renderingName `
  dictionaryPath $vxaDictionaryBranchPath `
  dictionaryEntries $dictionaryEntries
```