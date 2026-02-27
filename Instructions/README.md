# Instructions

Instructions are a detailed knowledge set. They represent reusable information that the chatbot needs to know about a specific tool or technology you plan to use. You should consider adding things you want it to do, things you don't want it to do and things it should make a decision about based on the context. Instructions can and should be broken up into atomic reusable parts and then included in your main instructions file by reference allowing you the ability to toggle on and off (by commenting in or out) the reference to the atomic files. This will help you manage your context. You may also do this by surfacing your instructions through skills which will load the instructions only when called. GitHub Copilot uses a single file, that has a fixed path and name convention, that is loaded into every conversation by default. 

## Copilot Instructions

Setting up instructions for GitHub Copilot requires you to create a folder and file in the root folder of your project: .github/copilot-instructions.md. An example is provided in this folder. 