@{
    # Disable "assigned but never used" for this workspace.
    # Template files (_Template-*.ps1) intentionally declare all available
    # template/rendering IDs as reference constants -- not all will be used
    # in every script generated from the template.
    Rules = @{
        PSUseDeclaredVarsMoreThanAssignments = @{
            Enable = $false
        }
    }
}
