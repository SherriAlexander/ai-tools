---
name: 'XMC Sitecore Page Creation Instructions'
description: 'Instructions for creating Sitecore pages using SPE scripts.'
applyTo: '**/*.ps1'
---

# Sitecore Page Creation
A sitecore page is a primary data element that represents a website page and will be used to define the structure of a URL. These pages can be added in a tree structure within the Sitecore content management system. When creating a Sitecore page item, it is essential to define at least the page definition which will represent the where the user interaction begins. There are several key elements to ensure that the page functions correctly and meets the page requirements. The following sections outline the variables and data structures you must define and pre-existing functions you may use to create a Sitecore rendering using Sitecore Powershell Extension (SPE) scripts.

## SCRIPT HEADER : REQUIRED
To call the pre-existing SPE functions, it is essential to include a script header that imports the necessary variables and functions required for the rendering creation process. The script header should include the following:

### Example : Script Header
```powershell
# <jira-key> : <rendering-name>

Get-Item -Path "master:" -ID "{FB25AA0F-AB22-46E4-80A7-512423378337}" | Invoke-Script # Devices
Get-Item -Path "master:" -ID "{56EDD942-A2E1-476B-AE4F-A13B9E3A9437}" | Invoke-Script # Item Ids
Get-Item -Path "master:" -ID "{775B9E6D-6B36-47CE-8F09-2EA0B14B5A94}" | Invoke-Script # Layouts
Get-Item -Path "master:" -ID "{2BFE54C1-1B01-4833-AAC3-07926E18C606}" | Invoke-Script # Lookups
Get-Item -Path "master:" -ID "{0BA7264C-D872-43D8-B61E-C909B7BE58F7}" | Invoke-Script # Paths
Get-Item -Path "master:" -ID "{80BD81F4-E138-420A-BE4D-88F483924957}" | Invoke-Script # Template Ids

Import-Function Create-PlaceholderSettings
Import-Function Set-ItemField
Import-Function Create-ItemIfNotExists
Import-Function Write-SectionEntry
Import-Function Write-SectionHeader
Import-Function Create-PageBranchTemplate
Import-Function Create-PageTemplate
Import-Function Create-PartialAndPageDesigns
Import-Function Get-MatchingBaseTemplates
```

## PAGE NAME : REQUIRED
The name of the page template should be defined in a variable for use in the functions that create the page template and other related elements. This value should be derived from the JIRA ticket title. The page name should be prefixed with "VXA". For example if the page name is "Article Page", then the $pageName should be set to "VXA Article Page". 

```powershell
$pageName = <page-name>
```

## PAGE DEFINITION : REQUIRED
When defining a page template, you will need to define which fields are available to store data for content authors to modify the content, behavior or design of the page. The page template is used as a master copy that authors will use to create new pages from to build the hierarchical tree of their website. The page template should be created using the Create-PageTemplate function in the SPE scripts. The page definition should be a powershell variable that will be used when creating the page template. If a section is not defined, the default value for a section is "Data".

### Example : page definition
This is how a data table would be represented in powershell. Use this as a guide but always refer to the JIRA ticket for the specific values and not this example. This is only a guide to demonstrate the structure. The page definition should include all table properties even if they are empty and those properties are: name, title, section, fieldType, fieldSource, required, defaultValue.

```powershell
$pageDefinition = @(
    @{ name = "primaryImage"; title = "Primary Image"; section = "Image"; fieldType = "Image"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "title"; title = "Title"; section = "Title"; fieldType = "Single Line Text"; fieldSource = ""; required = $true; defaultValue = "`$name" },
    @{ name = "shortTitle"; title = "Short Title"; section = "Title"; fieldType = "Single Line Text"; fieldSource = ""; required = $false; defaultValue = "`$name" },
    @{ name = "headerTitle"; title = "Header Title"; section = "Title"; fieldType = "Single Line Text"; fieldSource = ""; required = $false; defaultValue = "`$name" },
    @{ name = "subtitle"; title = "Subtitle"; section = "Title"; fieldType = "Single Line Text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "backgroundImage"; title = "Background Image"; section = "Multimedia"; fieldType = "Image"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "excerpt"; title = "Excerpt"; section = "Text"; fieldType = "Rich Text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "Copy"; title = "copy"; section = "Text"; fieldType = "Rich Text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "generalTagging"; title = "General Tagging"; section = "Taxonomy"; fieldType = "Multi-Select with search"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "suppressInSubNav"; title = "Suppress in Sub-Navigation"; section = "Navigation"; fieldType = "Checkbox"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "noIndex"; title = "No Index"; section = "Index"; fieldType = "Checkbox"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "noFollow"; title = "No Follow"; section = "Index"; fieldType = "Checkbox"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "excludefromSitemap"; title = "Exclude from Sitemap "; section = "Index"; fieldType = "Checkbox"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "metadataTitle"; title = "Metadata Title"; section = "Page Metadata"; fieldType = "Single Line Text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "metadataKeywords"; title = "Metadata Keywords"; section = "Page Metadata"; fieldType = "text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "metadataDescription"; title = "Metadata Description"; section = "Page Metadata"; fieldType = "text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "metadataImage"; title = "Metadata Image"; section = "Page Metadata"; fieldType = "text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "Javascript"; title = "Javascript"; section = "Custom Code"; fieldType = "Multi Line Text"; fieldSource = ""; required = $false; defaultValue = "" },
    @{ name = "css"; title = "CSS"; section = "Custom Code"; fieldType = "Multi Line Text"; fieldSource = ""; required = $false; defaultValue = "" },
```

### Example : creating a datasource template using the Create-PageTemplate function
```powershell
$pageTemplate = Create-PageTemplate `
    -pageName $pageName `
    -pagePath $vxaPageTemplatePath `
    -pageDefinition $pageDefinition `
```

## PLACEHOLDER SETTINGS : REQUIRED

### Example : creating the placeholder settings using the Create-PlaceholderSettings function
```powershell
Create-PlaceholderSettings -pageName $pageName
```

## PARTIAL DESIGN AND PAGE DESIGN : REQUIRED

### Example : creating the partial and page designs using the Create-PartialAndPageDesigns function
```powershell
Create-PartialAndPageDesigns -pageName $pageName
```

## PAGE BRANCH TEMPLATE : REQUIRED

### Example : creating the page branch template using the Create-PageBranchTemplate function
```powershell
Create-PageBranchTemplate -pageName $pageName -templateId $pageTemplate.ID
```