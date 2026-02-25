# AI Resources

The AI Resources repository is a single location for Velir to gather and share the growing body of files that help guide our AI-enabled workloads. Everyone should feel welcome to contribute and not expect a high level of requirements. This is a fast evolving area of development and we should move equally quickly. I personally recommend (although it is not required and should not be so important as to slow you down) that you prefix files you create with the name of the technology so they can naturally sort together. You should balance the need to share valuable things with a modicum of good housekeeping. Don't let it hobble you, but at least give it passing consideration.

# Mental Framework

This is a fast evolving technology and it may not all be intuitive. What follows is a short explainer to help you ramp up on the basic concepts.

## Models

When you use an AI chatbot, they are considered a model. As in they are a model of our language. They originally were word predictors. You started a conversation and it would predict an answer. That's no longer all they are. They are also trained to understand problem solving, and objectivity. What this means is that you can ask it to handle a sophisticated problem and it can 'think' about it before coming to a conclusion. It can request to use tools like a browser. It won't use it directly but will respond that a tool should be called and provide the parameters for those tools. Models come in different sizes, usually small, medium and large. Small are only able to handle less complex subjects, medium sized models are general purpose and large models are fantastic at intensely creative projects and research endeavors. Most frontier models (made by the big companies) are multilingual. They can natively speak around 40 languages. 

## Context 

When you think about how to conceptualize how you interact with an AI chatbot, the text you provide can be simple or very complex. It may be reusable or dynamic. It may even contain files. What you need to understand is that all of what you provide during your conversation is context. How well the model performs is mostly dependent on how good the context is. At a minimum a basic chat is you providing your text, also called a prompt. If you repeat yourself often enough, and the text is long enough, you'll want to abstract it to an instruction file. These instructions are written in Markdown language and provide background for the conversation you're about to have (as in they are provided to the model before your prompt). Depending on what you want to accomplish, you may want to include different sets of instructions or even attach files.

## Tools and Agents

If you want a model to take an action, you can provide tools for it to use. This generally has been done through the use of MCP servers. MCP servers are wrappers generally for APIs but it is simply a server that the host (Copilot) can talk to and ask to run a function. You can create an MCP server in any language but I would recommend you do it in Node (exported to npm) so it's light and portable. Anything you can do in Node, you can then provide as a tool with a description and a model can then use it. Models don't directly call tools. The application wrapping it does, whether it's Copilot or a custom built web application with direct model API access. This means you can and should govern it. All tools you provide are done as context and the more you provide, means you will consume some of the limited context window your model has. 

## Context Window

When you have a conversation with a model, you're sending all of the prompts, instructions and tools you've added up to that point every time you submit. This total volume needs to fit in the context window of your model. If you exceed that window, you will lose some of your context and the conversation will degrade. The context windows are growing with each new model release but you should be aware of how large they are for the model you're using and when you're getting close. Copilot now shows you how much you've consumed.

## Conversations

Conversations should be considered as individual tasks or questions. If you have too wide of a conversation, you're likely going to get a poor response because the model both may spill outside of it's context window or because it can't focus on the topic as well as if it were a narrower topic. There is no cost to having new conversations, so start them often. You can also come back to a conversation and continue it later if you leave yourself some remaining context window. 

## Tokens

Model usage is often measured in tokens used. Tokens are fragments of a word. Similar to how documents are compressed with zip software, tokens are used to compress all the words in a language. Tokens are simply parts of words. Each company uses different tokenizers but generally they help reduce the number of repeatable sequences in any given body of text. An example of a tokenizer can be found here: https://platform.openai.com/tokenizer. The general rule for comparing words to tokens is to assume for every 75 words will consume 100 tokens. Every time a conversation is send back to a model, and it continues to grow, it is tokenized. This means that it will consume more tokens with every response. This is somewhat mitigated by a caching layer most companies provide that will store the previous token chain for a short-ish period of time (usually enough for you to have a full conversation). In essense, token usage is very hard to estimate. 

# Repository Structure

There's some light expectations around where to put what you create. We've started with a few buckets depending on what you're attempting to accomplish. 

## Instructions

Instructions files should be considered in-depth knowledge. The Instructions folder are where to keep atomic knowledge for different specific technologies and tasks. Examples would be for JIRA. There may be different instruction files for reading different types of tickets. 

## Skills

Skills are a layer above instructions. Where an individual instruction may explain how to read a ticket or construct a file, a skill would use those instructions to complete a task. For example, you may want to create a skill for any number of repetitive tasks like commenting or reviewing code after you've made changes. Or you may want to refactor out duplicate code. These skills become command line functions you can call instead of attaching instructions. Think of it as dynamically loading instructions for a specific task. 

## Agents

Agents further build upon skills and instructions. Agents by definition are intended to work autonomously. The idea of an agent is to work interactively to generate enough context that you can allow the agent to work on a large task for a long time. Some of the most complex agents will utilize other sub-agents to complete a task but this is not something we typically will see yet. It's something you must explicitly know how to do. An example of an agent we have developed internally was capable of reading a list of JIRA tickets and generating fully functioning React components. This required a detailed explanation of how to read tickets and format code as well as an infrastructure of Powershell scripts to create serialized data structures in Sitecore. The limits of what an agent can do is how detailed the instructions are and what tools it can access. Many things are still not entirely accessible like desktop applications and web services that lack APIs. There are still possibilities we can solve those problems with browser automation but we'll tackle those problems as we get there.