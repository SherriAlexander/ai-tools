# Enumerations

Sitecore Enumerations (Enums) are created or updated using the PowerShell script `Create-OrUpdateEnum.ps1` located at `spe/scripts/Create-OrUpdateEnum.ps1`. 

## Required Procedure (Instruction-First)

When generating an enumeration script, follow this sequence in order:

1. Read this instruction file first and treat it as the source of truth.
2. Retrieve ticket details from Jira (summary, values, and any path exceptions).
3. Determine whether the ticket is an enum or taxonomy based on the ticket summary/content.
4. Generate the script using the rules in this file.
5. Optionally compare against existing scripts only for formatting consistency.

Do not infer implementation rules from existing ticket scripts before applying this guidance. Existing scripts may have been generated under older instructions and are not authoritative.

Jira feature tickets contain the requirements for enumerations, such as taxonomy or display options, that need to be created in the CMS. You can extract the parent path, folder name, and values from the tickets to supply to the script. The ticket number should be provided by the user. If one is not provided them request it.

## The `Create-OrUpdateEnum` Function

The Script provides a helper function `Create-OrUpdateEnum` that ensures the parent folder exists (using the `$FolderTemplateId`) and loops through all `$EnumNames` to create items (using the `$EnumTemplateId`).

The parameters needed are:
* **`$ParentPath`**: The Sitecore path where the enumeration folder should live (e.g., `"master:/sitecore/content/Global/Enums"`).
* **`$FolderName`**: The name of the folder storing the enum values.
* **`$FolderTemplateId`**: The Sitecore Template ID used to create the grouping folder if it does not yet exist.
* **`$EnumTemplateId`**: The Sitecore Template ID used to create individual enumeration item options.
* **`$ValueFieldName`**: The name of the field on the enumeration item where the value should be stored (defaults to `"value"`).
* **`$EnumNames`**: A string array containing the list of values to be created.

## Examples from Jira Tickets

When creating enumerations based on Jira tickets, review the "Values" section for the array of enum names, and the ticket's "Summary" for the intended folder name. 

The output should be generated as a standalone PowerShell script (`.ps1`) located in the project-relative folder `spe/enums/`. It is important that each Jira ticket has its own dedicated script, and the file name must perfectly match the Jira ticket number (e.g., `ASHRR-156.ps1`). The script needs to dot-source several helper functions (including `Create-OrUpdateEnum`, `Create-ItemIfNotExists`, and `Set-ItemField`), define the variables using data from the ticket, and then execute the main function. The script should always use `"master:/sitecore/templates/Branches/Feature/Velir Experience Accelerator/VXA Site Collection Settings/vxaSiteCollectionSettings/Settings/Enumerations"` as the enumeration parent path, unless another path is explicitly specified.

### Example 1 (ASHRR-156: ENUM: Number of Columns)
The requirement specifies a "Number of Columns" enumeration with values: `2`, `3`, `4`.

```powershell
# File: spe/enums/ASHRR-156.ps1

# Import helper functions
Import-Function Create-ItemIfNotExists
Import-Function Set-ItemField
Import-Function Create-OrUpdateEnum

# Variables derived from ticket
$enumFolderName = "Number of Columns"
$enumParentPath = "master:/sitecore/templates/Branches/Feature/Velir Experience Accelerator/VXA Site Collection Settings/vxaSiteCollectionSettings/Settings/Enumerations" 
$enumFolderTemplateId = "{64417ED1-E70E-4A9E-A8CA-637DCF9D19DB}"
$enumItemTemplateId = "{D060EC1A-B7CB-4F6B-A8AE-668E1A3CD081}"
$enumValueFieldName = "value"
$enumValues = @("2", "3", "4")

$params = @{
    ParentPath       = $enumParentPath
    FolderName       = $enumFolderName
    FolderTemplateId = $enumFolderTemplateId
    EnumTemplateId   = $enumItemTemplateId
    ValueFieldName   = $enumValueFieldName
    EnumNames        = $enumValues
}

Create-OrUpdateEnum @params
```

### Example 2 (ASHRR-159: TAX: Content Type)
A Taxonomy is a special kind of enumeration. When creating an enumeration for a taxonomy (often prefixed with "TAX:" in Jira), you must use specific template IDs and field names. The taxonomy template ID is `{2BA9F31C-6F86-46E9-99AB-4D264DE192F2}` for the item, the folder template ID is `{814F256E-48D2-401E-820D-48FE3B13EAB5}`, and the value field name must be set to `"title"`. The parent path for taxonomies should be `"master:/sitecore/templates/Branches/Feature/Velir Experience Accelerator/VXA Taxonomy/VxaTaxonomyFolder/$name"`. The dollar sign must be escaped.

The requirement specifies a "Content Type" taxonomy with multiple values such as `Award`, `Patient Education`, `Advocacy`, etc.

```powershell
# File: spe/enums/ASHRR-159.ps1

# Import helper functions
Import-Function Create-ItemIfNotExists
Import-Function Set-ItemField
Import-Function Create-OrUpdateEnum

# Variables derived from ticket
$folderName = "Content Type"
$taxParentPath = "master:/sitecore/templates/Branches/Feature/Velir Experience Accelerator/VXA Taxonomy/VxaTaxonomyFolder/`$name" 
$taxFolderTemplateId = "{814F256E-48D2-401E-820D-48FE3B13EAB5}"
$taxItemTemplateId = "{2BA9F31C-6F86-46E9-99AB-4D264DE192F2}"
$taxValueFieldName = "title"
$taxValues = @(
    "Award", 
    "Patient Education", 
    "Advocacy", 
    "Meeting", 
    "Abstract", 
    "Article/News", 
    "Program/Initiative", 
    "Guideline", 
    "Resource", 
    "Toolkit"
)

$params = @{
    FolderName       = $folderName
    ParentPath       = $taxParentPath
    FolderTemplateId = $taxFolderTemplateId
    EnumTemplateId   = $taxItemTemplateId
    ValueFieldName   = $taxValueFieldName
    EnumNames        = $taxValues
}

Create-OrUpdateEnum @params
```
