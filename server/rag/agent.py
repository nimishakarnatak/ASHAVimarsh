import os
from typing import Optional, List

from google.adk.agents import Agent
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from google.adk.tools import google_search
# from google.adk.tools.vision import ImageAnalysisTool  # Uncomment if available for diagnostic reports

from vertexai.preview import rag

from dotenv import load_dotenv
from .prompts import (
    return_instructions_root, 
    return_instructions_training, 
    return_instructions_forum, 
    return_instructions_web_search, 
    return_instructions_diagnostic
)
load_dotenv()

training_rag_tool = VertexAiRagRetrieval(
    name='asha_training_retrieval',
    description='Retrieves information from ASHA workers training modules',
    rag_resources=[
        rag.RagResource(
            rag_corpus=os.environ.get("RAG_CORPUS")
        )
    ],
    similarity_top_k=20,
    vector_distance_threshold=1.0,
)

forum_rag_tool = VertexAiRagRetrieval(
    name='forum_retrieval',
    description='Retrieves information from forum discussions',
    rag_resources=[
        rag.RagResource(
            rag_corpus=os.environ.get("FORUM_CORPUS")
        )
    ],
    similarity_top_k=20,
    vector_distance_threshold=0.4,
)

# ============================================================================
# SUB-AGENTS DEFINITION
# ============================================================================

# 1. Training Module Sub-Agent
training_sub_agent = Agent(
    model='gemini-2.5-flash',
    name='training_module_agent',
    instruction=return_instructions_training(),
    description='Specialized sub-agent for ASHA training module queries and official protocols',
    tools=[training_rag_tool]
)

# 2. Forum Sub-Agent  
forum_sub_agent = Agent(
    model='gemini-2.5-flash',
    name='forum_agent',
    instruction=return_instructions_forum(),
    description='Specialized sub-agent for forum discussions and community Q&A',
    tools=[forum_rag_tool]
)

# 3. Web Search Sub-Agent (with error handling for missing GoogleSearchTool)
web_search_sub_agent = Agent(
    model='gemini-2.5-flash',
    name='web_search_agent',
    instruction=return_instructions_web_search(),
    description='Specialized sub-agent for web search and current medical information',
    tools=[google_search]
)

diagnostic_tools = []
# Add diagnostic tools when available
# if ImageAnalysisTool:
#     diagnostic_tools.append(ImageAnalysisTool())

diagnostic_sub_agent = Agent(
    model='gemini-2.5-flash',
    name='diagnostic_agent',
    instruction=return_instructions_diagnostic(),
    description='Specialized sub-agent for analyzing diagnostic reports and medical documents',
    tools=diagnostic_tools  # Will be empty initially, add tools as needed
)

# ============================================================================
# ROOT ORCHESTRATOR AGENT WITH SUB-AGENTS
# ============================================================================

root_agent = Agent(
    model='gemini-2.5-flash',
    name='asha_root_orchestrator',
    instruction=return_instructions_root(),
    description=(
        'Main ASHA assistant orchestrator that coordinates between specialized sub-agents '
        'for training modules, forum discussions, web search, and diagnostic analysis.'
    ),
    tools=[],  # Root agent has no direct tools, only orchestrates sub-agents
    sub_agents=[
        training_sub_agent,
        forum_sub_agent, 
        web_search_sub_agent,
        diagnostic_sub_agent
    ]
)