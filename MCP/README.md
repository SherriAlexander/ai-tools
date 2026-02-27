# MCP Servers

MCP Servers are a standard application that allows a chatbot to communicate with it. This often takes the shape of an API wrapper but it can be used to wrap any functionality. MCP Servers can be built on any server technology as long as they conform to the spec. 

## Getting Connected

Some servers are hosted by the company who built them like with Atlassian or Sitecore. Others you run on your local. Running locally means you have to know what technology they were built with so you can have it installed before running it. There are several standard technologies including Docker, NPM, and Python. Be aware of which it is and where it runs. This is most of the challenge of getting connected. 

## Host Environments

The way an MCP server is configured depends on which host you use. Many at Velir have GitHub Copilot or Claude Code. Each has similar but slightly varying ways of doing it. If you're not sure how to do it, you can generally Google it or ask the chatbot itself to initiate the configuration for you. 

## Server Configurations

To be able to connect means having a way to tell your host what MCP servers it can use through a server configuration. These all generally live in one file. For GitHub Copilot this is in a folder and file in the root folder of your project: .vscode/mcp.json. An example is provided in this folder. 

## Running a Server

When you open the mcp.json file in VS Code, you should see a highlight above each server allowing you to start it. When you do it should display that it is running. If not, the output window should explain why. It may be that you do not have that technology installed or are not logged into an externally hosted server. Reach out or ask the chatbot to help you identify the issue. Once it is running the tools are available to your chat and you should be able to ask it to connect to the system and interact with it. You will be prompted for allowance when it tries to connect. You can allow it once, for the session or forever. I highly recommend only allowing it once and always confirming what it is doing until you really feel you have a strong understanding of what it is doing. 